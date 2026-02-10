function s = salvusComputeResults(s, plotTrue, rawsel)

if nargin<2
    plotTrue = false;
    rawsel = false;
end

for p = 1:length(s)
    if ~isempty(s(p).ap)
        dur_BaselineStabilityTime = s(p).ap.BaselineStableTime; %701; % time in seconds
        dur_BaselineTime = s(p).ap.BaselineTime; % 60; 
        dur_sampleToMeasStartTime = s(p).ap.SampleToMeasStartTime; %118; 
        dur_sampleRunTimeMeasCalc = s(p).ap.SampleRunTime; %  54; 
    
        times_sec = s(p).times_s - s(p).times_s(1) - dur_BaselineStabilityTime; %shift time vector so baselining begins at time=0
        
        baselineIndVec = find((s(p).times_s > (s(p).times_s(1) + dur_BaselineStabilityTime)) & s(p).times_s < (s(p).times_s(1) + dur_BaselineStabilityTime + dur_BaselineTime));
        slopeIndVec = find((s(p).times_s > dur_sampleToMeasStartTime) & (s(p).times_s < (dur_sampleToMeasStartTime+dur_sampleRunTimeMeasCalc))); 
        % totalRespIndVec = s(p).sampleTransitions(1):slopeIndVec(end); 
    
        time_epoch = importTimeEpoch(s(p).filename);
        
        first_samp_time = time_epoch(slopeIndVec(1)+10);
        disp(['first samp time = ', num2str(first_samp_time)])
    
        for c = 1:4
            
    %         if isfield(s(p),'iFreqPost') && s(p).iFreq_selected(c)>0
    %             uwa = salvus_UWA_at_iFreq(s(p).fringe{c},s(p).iFreqPost_final(c));
            if rawsel
                uwa = s(p).uwa_rawsel{c};
            else
                uwa = s(p).uwa_raw{c};
            end 
    
    %         disp('---------')
    %         disp(['s(p).times_s(baselineIndVec(1)) = ', num2str(s(p).times_s(baselineIndVec(1)))]);
    %         disp(['s(p).times_s(baselineIndVec(end)) = ', num2str(s(p).times_s(baselineIndVec(end)))]);
    % 
    %         disp(['uwa(baselineIndVec(1)) = ', num2str(uwa(baselineIndVec(1)))]);
    %         disp(['uwa(baselineIndVec(end)) = ', num2str(uwa(baselineIndVec(end)))]);
    
            % baseline the data
            [p_coeff_BL, errEst_BL] = polyfit(times_sec(baselineIndVec),uwa(baselineIndVec),1);
            disp(['p_coeff_BL = ', num2str(p_coeff_BL)]);
            s(p).BAS_slope(c) = p_coeff_BL(1);
            s(p).BAS_slopeRsq(c) = 1 - (errEst_BL.normr/norm(uwa(baselineIndVec) - mean(uwa(baselineIndVec))))^2;
            s(p).plainLine_BL{c} = polyval(p_coeff_BL, times_sec,[]);
            s(p).uwa_baseline_corrected{c} = uwa - s(p).plainLine_BL{c};
            
            % calculate the results
            s(p).RES_totalResponse(c) = max(s(p).uwa_baseline_corrected{c}(slopeIndVec)) - min(s(p).uwa_baseline_corrected{c}(slopeIndVec));
            disp(['slopeIndVec(1) = ', num2str(slopeIndVec(1))]);
            disp(['slopeIndVec(end) = ', num2str(slopeIndVec(end))]);
    
    %         disp(['times_s(slopeIndVec(1)) = ', num2str(times_sec(slopeIndVec(1)))]);
    %         disp(['times_s(slopeIndVec(end)) = ', num2str(times_sec(slopeIndVec(end)))]);
            [p_coeff_RES, errEst_RES] = polyfit(times_sec(slopeIndVec), s(p).uwa_baseline_corrected{c}(slopeIndVec), 1);        
            s(p).plainLine_RES{c} = polyval(p_coeff_RES, times_sec,[]);
            s(p).RES_slope(c) = p_coeff_RES(1);
            s(p).RES_slopeRsq(c) = 1 - (errEst_RES.normr/norm(s(p).uwa_baseline_corrected{c}(slopeIndVec) - mean(s(p).uwa_baseline_corrected{c}(slopeIndVec))))^2;
            
            % print results        
            disp(['p = ' num2str(p), ', c = ', num2str(c), ', fn = ', s(p).filename])
            disp(['BaselineStabilityTime = ', num2str(dur_BaselineStabilityTime)])
            disp(['BaselineTime = ', num2str(dur_BaselineTime)])
            disp(['sampleToMeasStartTime = ', num2str(dur_sampleToMeasStartTime)])
            disp(['sampleRunTimeMeasCalc = ', num2str(dur_sampleRunTimeMeasCalc)])
            disp(['slope = ', num2str(s(p).RES_slope(c))])
            disp(['Rsq = ', num2str(s(p).RES_slopeRsq(c))])
            disp(['totResp = ', num2str(s(p).RES_totalResponse(c))])
    
            if plotTrue
    
                fig = figure;
        
                subplot(2,1,1)
                plot(times_sec, uwa,'b','LineWidth',2)
                hold on
                grid on
                plot(times_sec(baselineIndVec), s(p).plainLine_BL{c}(baselineIndVec),'r','LineWidth',1.5)        
                plot(times_sec(baselineIndVec(end)), uwa(baselineIndVec(end)),'ro')
                plot(times_sec(baselineIndVec(1)), uwa(baselineIndVec(1)),'ro')
                hold off
                title([s(p).filename, ', Channel ', num2str(c)],'Interpreter','none')
                xlabel('Time (s), from sample introduction')
                ylabel('UWA (radians), raw')
        
                subplot(2, 1, 2)
                plot(times_sec, s(p).uwa_baseline_corrected{c},'k','LineWidth',2)
                hold on
                grid on
                plot(times_sec(slopeIndVec), s(p).plainLine_RES{c}(slopeIndVec),'r','LineWidth',1.5)
                plot(times_sec(slopeIndVec(1)), s(p).uwa_baseline_corrected{c}(slopeIndVec(1)),'ro')
                text(times_sec(slopeIndVec(1)), s(p).uwa_baseline_corrected{c}(slopeIndVec(1)), 'sampleToMeasStart')
                plot(times_sec(slopeIndVec(end)), s(p).uwa_baseline_corrected{c}(slopeIndVec(end)),'ro')
                text(times_sec(slopeIndVec(end)), s(p).uwa_baseline_corrected{c}(slopeIndVec(end)), 'sampleRunTimeMeasCalc')
                plot(times_sec(s(p).sampleTransitions(1)), s(p).uwa_baseline_corrected{c}(s(p).sampleTransitions(1)),'ro')
                text(times_sec(s(p).sampleTransitions(1)), s(p).uwa_baseline_corrected{c}(s(p).sampleTransitions(1)),'Sample Introduced')
        
                hold off
                xlabel('Time (s), from sample introduction')
                ylabel('UWA (radians), baselined')
                fig.WindowState = 'maximized';
                pause(1)
                %close(fig)
            end
        end
    end
end

