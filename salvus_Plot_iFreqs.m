function s = salvus_Plot_iFreqs(s)

colors = {'#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4',...
    '#46f0f0', '#f032e6','#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324',...
    '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', ...
    '#808080',  '#000000'};

if nargin<2
    manualEntry=false;
end

for p=1:length(s)
    for c=1:4
        times_sec = s(p).times_ms./(60*1000);
        % find start and end indeces and add time in seconds on x-axis of plots
        if ~isempty(s(p).sampleTransitions)
            firstTrans = s(p).sampleTransitions(1);
            if (times_sec(firstTrans)-100/60)>0
                startWindow_s = times_sec(firstTrans)-100/60;
                startEdge = times_sec<startWindow_s; 
                startWindow_ind = find(abs(diff(startEdge))==1);
                startWindow_ind = startWindow_ind(1);
            else
                startWindow_ind = 1;
            end

            if (times_sec(firstTrans)+400/60)<times_sec(end)
                endWindow_s = times_sec(firstTrans)+400/60;
                endEdge = times_sec>endWindow_s;
                endWindow_ind = find(abs(diff(endEdge))==1);
                endWindow_ind = endWindow_ind(1);
            else
                endWindow_ind = length(times_sec);
            end
        
                startFig = figure;
        subplot(2,1,1)
        [times_xx, pixPos_yy, fringe] = fringeSurf(s, p, c);
        [~, cols] = size(fringe);
        surf(pixPos_yy,times_xx,fringe')
        colormap('gray')
        shading interp
        view(90,270)
        xlim([1, cols])
        xlabel(['Channel ', num2str(c), ' Fringe'])
        ylim([min(min(times_xx())), max(max(times_xx))])
%         if times_sec(startWindow_ind) ~= times_sec(endWindow_ind)
%             ylim([times_sec(startWindow_ind), times_sec(endWindow_ind)])
%         end
        title([s(p).filename, ' Channel ', num2str(c)],'Interpreter','none')



        % fetch the frequency domain matrix for the current file/channel
%         [~, F] = recalc_uwa_at_iFreq_2(s,p,c);
        
        % range of frequency bins to search for max magnitude
        iFreq_start = 10;
        iFreq_end = 14;

        subplot(2,1,2)
        yyaxis right
        row = length(times_sec);
%         [row, ~] = size(F);
        sT = zeros(1,row);
        sT(s(p).sampleTransitions)=1;
        stem(times_sec,sT,'Color','k')
        
        for f = iFreq_start:iFreq_end
            
            yyaxis left
%             s(p).uwa_at_iFreq{c,f} = -unwrap(angle(F(:,f)));
            label = strcat("ifreq = ",num2str(f));
            legend
            
            plot(times_sec, s(p).uwa_at_iFreq{c,f} - s(p).uwa_at_iFreq{c,f}(500),...
                'DisplayName',label,'LineWidth',2, 'Color', colors{f-iFreq_start+1},...
                'Marker','none','LineStyle','-')
            grid on
            legend show
            hold on
        end
        xlim([min(times_sec) max(times_sec)])
%         if times_sec(startWindow_ind) ~= times_sec(endWindow_ind)
%             xlim([times_sec(startWindow_ind), times_sec(endWindow_ind)])
%         end
        ylabel('UWA at iFreq (radians)')
        xlabel('Time (min)')
        title([s(p).filename(1:end-4), ' Channel ', num2str(c)],'Interpreter','none')
        startFig.WindowState = 'maximized';
%         fn=[s(p).filename(1:end-4), '_C', num2str(c), '_multi_iFreq.png'];
%         saveas(startFig,['pfoa_file' num2str(p), '_chan' num2str(c)],'png')

        filename = s(p).filename;
        newfilename = strcat(filename(1:end-4),'_',num2str(c),'_multi_iFreq');
        patt = 'Salvus_DevPortal_Log_';
        lpatt = length(patt);
        rm = strfind(newfilename,patt);
        newfilename(rm:rm+lpatt-1) = [];
        saveas(startFig,newfilename,'png')
        
        close(startFig)
        end
        disp(['file: ',num2str(p),'/', num2str(length(s)), '  ', 'channel: ', num2str(c)]);
    end
end