function s = salvus_iFreq_postSelector_segment(s)

%d = designfilt('highpassiir','StopbandFrequency',0.05901,'PassbandFrequency',...
%    0.07,'StopbandAttenuation',60,'PassbandRipple',0.1,'DesignMethod','ellip');

% d=designfilt('highpassiir','StopbandFrequency',.02,'PassbandFrequency',.07,'StopbandAttenuation',15,'PassbandRipple',4);

% instead of using the tight filter above, use the same coefficients we use
% in the C++ implementation
filt_A = [ 1.0000, -1.7919, 0.8116 ];
filt_B = [ 0.9009, -1.8018, 0.9009 ];

% fringe spatial period in cycles per pixel; typical values:
fringePeriod_min = 0.08; 
fringePeriod_max = 0.11; 
gROI_width = 128;
noise_margin = 3;

% converting spatial frequency to index in the frequency domain 
iFreq_start = round(fringePeriod_min * gROI_width,0); %needs to be an integer
iFreq_end = round(fringePeriod_max * gROI_width,0);
%iFreq_start = 10;
%iFreq_end = 14;

disp(['iFreq_start=' num2str(iFreq_start)])
disp(['iFreq_end=' num2str(iFreq_end)])



colors = {'#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4',...
    '#46f0f0', '#f032e6','#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324',...
    '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', ...
    '#808080',  '#000000'};

hanning_window = hanning(gROI_width)';
for p=1:length(s)




    if ~isempty(s(p).sampleTransitions) && ~isempty(s(p).ap)    
        % pull in transition times that were obtained from
        % assayParameters.log
        
        dur_sampleToMeasStartTime = s(p).ap.SampleToMeasStartTime; 
        dur_sampleRunTimeMeasCalc = s(p).ap.SampleRunTime;
        slopeIndVec = find((s(p).times_s >= 0) & (s(p).times_s < (dur_sampleToMeasStartTime+dur_sampleRunTimeMeasCalc))); 

        %define transition times. We'll ultimately be interested in the
        %best iFreq in the epoch between seg1end and seg2end
        seg1end = slopeIndVec(1);
        seg2end = slopeIndVec(end);
        lastInd = length(s(p).times_s);
        seg.ind{1} = 1:seg1end;
        if length(s(p).sampleTransitions) > 1
            seg.ind{2} = (seg1end+1):seg2end;%(s(p).sampleTransitions(1)+1):s(p).sampleTransitions(2); 
            seg.ind{3} = (seg2end+1):lastInd; %(s(p).sampleTransitions(2)+1):lastInd; 
            spnum = 3;
        else
            seg.ind{2} = (s(p).sampleTransitions(1)+1):lastInd;
            seg.ind{3} = [];
            spnum = 2;
        end

        for c=1:4
            sips = figure;

            % iterate through each segment (we're really only interested in
            % the second (k=2) segment which is between sample intro and
            % sampleMeas time. 
            for k=1:spnum
                
                plotrows = 4;

                subplot(plotrows,spnum,k + (spnum * 0))
            
                fringe_full = s(p).fringe{c};
                fringe = fringe_full(seg.ind{k},:);
                [~, col] = size(fringe); 
                times = s(p).times_s(seg.ind{k});
                [times_xx, pixPos_yy] = meshgrid(times, 1:col);
                surf(pixPos_yy,times_xx,fringe')
                colormap('gray')
                shading interp
                view(90,270)
                xlabel('xPix Pos')
                ylabel('time (sec)')
                xlim([1,128])
                if k==1
                    title('Baseline Stability Start to Baseline End')
                elseif k==2
                    title('Sample Introduced to Extra Sample End')
                elseif k==3
                    title('Running Buffer Flush')
                end
                ylim([times(1), times(end)])
                
                %filter fringe pattern matrix and compute the FFT mag
                %fringeFilt = filtfilt(d,fringe');
                fringeFilt = filtfilt(filt_B,filt_A,fringe');
                fringeFilt = fringeFilt'.*hanning_window;
                F = fft(fringeFilt, [],2);
                mag = abs(F);

                % Go ahead and record the full fringe pattern
                fringe_full_filt = filtfilt(filt_B,filt_A,fringe_full');
                fringe_full_filt = fringe_full_filt'.*hanning_window;
                s(p).fringe_filt{c} = fringe_full_filt;
                mag_full = abs(fft(fringe_full_filt,[],2));
                noise_full = (sum(mag_full(:,1:(iFreq_start - noise_margin)),2) + sum(mag_full(:,iFreq_end + noise_margin):(round(gROI_width/2,0)),2)) /...
                    numel([(1:(iFreq_start - noise_margin)) (iFreq_end + noise_margin):(round(gROI_width/2,0))]);
                

                subplot(plotrows,spnum, k + (spnum * 1) )
                surf(pixPos_yy,times_xx,mag')
                colormap('gray')
                shading flat
                view(90,270)
                xlim([1,20])
                ylim([times(1), times(end)])
                xlabel('FFT bin')
                ylabel('time (sec)')


                subplot(plotrows,spnum,k + (spnum * 2))
                
                %postMag = mean(mag,1);
                noise = (sum(mag(:,1:(iFreq_start - noise_margin)),2) + sum(mag(:,iFreq_end + noise_margin):(round(gROI_width/2,0)),2)) / numel([(1:(iFreq_start - noise_margin)) (iFreq_end + noise_margin):(round(gROI_width/2,0))]);
                postMag = mag./noise; 
                postMag = mean(postMag,1);
                if sum(postMag)>0 % this is really just checking if there is data in the channel
                    % find the maximum fft magnitude within our iFreq
                    % window of interest
                    [maxMag, imaxMag] = max(postMag(iFreq_start:iFreq_end));
                    if (c==4) && (k==2)
                        fileoutmat = mag(:,iFreq_start:iFreq_end);
                        writematrix(fileoutmat,'outfile.csv');
                    end
                    
                    iFreq_post = imaxMag+iFreq_start-1;
                    noise = mean([postMag(1:(iFreq_start - noise_margin)), postMag((iFreq_end + noise_margin):(round(gROI_width/2,0)))]);
                    plot(postMag./noise) % this is really SNR to make the plots more comparable
                    
                    xlim([1,20])
                    xlabel('FFT bin')
                    ylabel('Avg FFT mag')
                    hold on
                    plot(iFreq_post,maxMag./noise,'r*')
                    set(gca,'YScale','log')
                    grid on
                    ylim([1e0, 1e3])

                    text(iFreq_post+1, maxMag./noise, [num2str(iFreq_post), ', ', num2str(round(maxMag./noise))])
                    s(p).iFreqPost{c,k} = iFreq_post; 
                    filename = s(p).filename;
                    newfilename = strcat(filename(1:end-4),'_',num2str(c),'_iFreqPS');



                    subplot(plotrows,spnum,k + (spnum * 3))
                    yyaxis right
        
                    [row, ~] = size(mag);
                    if ~isempty(s(p).sampleTransitions)
                        sT = zeros(1,row);
                        sT(s(p).sampleTransitions)=1;
                        %times_sec = s(p).times_ms./(60*1000);
%                         stem(times(s(p).sampleTransitions),sT(s(p).sampleTransitions),'Color','k')
                    end
        
                    for f = iFreq_start:iFreq_end
                        
                        yyaxis left
                        a(p).uwa_at_iFreq{c,f} = -unwrap(angle(F(:,f)));
                        label = strcat("ifreq = ",num2str(f));
                        legend
                        
                        q(f) = plot(times, a(p).uwa_at_iFreq{c,f} - a(p).uwa_at_iFreq{c,f}(1),...
                            'DisplayName',label,'LineWidth',1, 'Color', colors{f-iFreq_start+1},...
                            'Marker','none','LineStyle','-');
                        if f==iFreq_post
                            q(f).LineStyle = '-';
                            q(f).Color = 'k';
                            q(f).LineWidth = 2;
                        end
                        grid on
                        legend show
                        hold on
                        
                    end
                    ch = get(gca,'children');
                    topline = ch(iFreq_end - iFreq_post+1);
                    ch(iFreq_end - iFreq_post+1)=[];
                    set(gca,'children',[topline; ch])
                    ylabel('UWA at iFreq (radians)')
                    xlabel('Time (min)')
                    xlim([times(1), times(end)])
                    if k==2
                        title([s(p).filename(1:end-4), ' Channel ', num2str(c)],'Interpreter','none')
                    end
                    sips.WindowState = 'maximized';
                    saveas(sips,newfilename,'png')

                else
                    s(p).iFreqPost{c,k} = 0;
                end
            end
            
            s(p).iFreq_selected(c) = s(p).iFreqPost{c,2}; % likely subtract 1 for the correct iFreq in C++ (triple check this)
            


            if s(p).iFreq_selected(c)>0
                s(p).uwa_rawsel{c} = salvus_UWA_at_iFreq(fringe_full_filt, s(p).iFreq_selected(c));
                s(p).snr_sel{c} = mag_full(:,iFreq_post)./noise_full;
            else
                s(p).uwa_rawsel{c} = zeros(length(s(p).times_s),1); 
                s(p).snr_sel{c} = zeros(length(s(p).times_s),1);
            end

            disp(['iFreq selected for channel ' num2str(c), ' was ' num2str(s(p).iFreq_selected(c))])
            disp(['iFreq post selected: ', num2str(p), ' of ', num2str(length(s)), ', channel ', num2str(c)])
            close(sips)
            
        end  
    else
        for c = 1:4
            s(p).uwa_rawsel{c} = s(p).uwa_raw{c};
        end
    end
    % Go ahead and record the full fringe pattern
    fringe_full = s(p).fringe{c};
    fringe_full_filt = filtfilt(filt_B,filt_A,fringe_full');
    fringe_full_filt = fringe_full_filt'.*hanning_window;
    F_full = fft(fringe_full_filt,[],2);

    % save all UWAs at iFreqs
    for c=1:4
        for f = iFreq_start:iFreq_end
            s(p).uwa_at_iFreq{c,f} = salvus_UWA_at_iFreq(s(p).fringe_filt{c},f);
        end
        s(p).fringe_filt{c} = fringe_full_filt; 
        s(p).fringe_FD{c} = F_full; 
    end

end
disp('Finished iFreq Post Selector.')