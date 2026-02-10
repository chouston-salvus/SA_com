function s = salvusMarkerTiming(s)

dwellTime_ms = 20 * 1000; % length of time immediately prior to the sample start to exclude from the baseline, milliseconds
baselineTime_ms = 60 * 1000; % length of time immediately prior to dwell time to use for baselining, milliseconds 

for p=1:length(s)   
    times_ms = fillmissing(s(p).times_ms, 'linear');
    % can only calculate if we have a sample marker to key from
    if ~isempty(s(p).sampleTransitions) 
        firstSampInd = s(p).sampleTransitions(1); 
        % firstPumpInd = s(p).bufferTransitions(1);

        if ~isempty(s(p).pumpOnTransitions) % if we ever turn the pump on,
            % we can assume this is a changeover-style test and can key our
            % baseline off the pump, still using the sample state to know
            % which pump transition is correct to use
            
            firstPumpOffInd = s(p).pumpOffTransitions(find(diff(s(p).pumpOffTransitions < firstSampInd)));
            % define time boundaries for baselining
            if ~isempty(firstPumpOffInd)
                startBaselineTime_ms = times_ms(firstPumpOffInd) - dwellTime_ms - baselineTime_ms; 
                endBaselineTime_ms = times_ms(firstPumpOffInd) - dwellTime_ms; 
                % zero time is when the pump starts back up only after it has
                % transitioned off.
                pumpOnAfterOff = s(p).pumpOnTransitions(s(p).pumpOnTransitions > firstPumpOffInd); 
                zeroInd = pumpOnAfterOff(1); 
            else
                [startBaselineTime_ms, endBaselineTime_ms, zeroInd]= recirc(times_ms, firstSampInd, dwellTime_ms, baselineTime_ms);
            end
        else 
            [startBaselineTime_ms, endBaselineTime_ms, zeroInd]= recirc(times_ms, firstSampInd, dwellTime_ms, baselineTime_ms);
        end
        s(p).baselineBoundsInd = [find(abs(diff(times_ms < startBaselineTime_ms))), find(abs(diff(times_ms > endBaselineTime_ms)))];
        % determine the nearest index matching the time boundaries
        startBaselineInd = find(abs(diff(times_ms>startBaselineTime_ms)));
        if startBaselineInd<0
            startBaselineInd = 100;
        end
        endBaselineInd = find(abs(diff(times_ms>endBaselineTime_ms)));
        if endBaselineInd<=startBaselineInd
            disp("Error")
        end

        % index vector for the baseline
        baseIndVec = startBaselineInd:endBaselineInd; 

        
%         for c=1:4
%             % linear regression on the unwrapped angle within the defined baseline boundaries 
%             [p_coeff, errEst, mu] = polyfit(times_ms(baseIndVec),s(p).uwa_rawsel{c}(baseIndVec),1);
% 
%             % compute R^2
%             s(p).Rsq_baseline{c} = 1 - (errEst.normr/norm(s(p).uwa_rawsel{c}(baseIndVec) - mean(s(p).uwa_rawsel{c}(baseIndVec))))^2;
% 
%             % compute line with calculated coefficients
%             plainLine = polyval(p_coeff, times_ms,[],mu);
% 
%             % correct the baseline drift
%             s(p).uwa_baseline_corrected{c} = s(p).uwa_rawsel{c} - plainLine;
%             disp(['Baselined ', num2str(p), ' of ', num2str(length(s)), ', channel ', num2str(c), '.'])
%         end            
%         % create a new time vector that is shifted with the sample
%         % transition at t=0, in seconds
        s(p).times_s = (times_ms - times_ms(zeroInd))/(1000);
% 
%         if isfield(s,'longFringe')
%             [p_coeff, ~, mu] = polyfit(times_ms(baseIndVec),s(p).uwa_long(baseIndVec),1);
%             plainLine = polyval(p_coeff, times_ms,[],mu);
%             s(p).uwa_long_bc = s(p).uwa_long - plainLine;
%         end
    else 
%         % if no sample transition markers are present, out=in
%         disp(['No transitions to baseline file ', num2str(p), ' of ', num2str(length(s)),'.'])
%         for c=1:4
%             s(p).uwa_baseline_corrected{c} = s(p).uwa_rawsel{c};
            s(p).times_s = (times_ms)/(1000);
%         end
    end
    
end
end

function [startBaselineTime_ms, endBaselineTime_ms, zeroInd]= recirc(times_ms, firstSampInd, dwellTime_ms, baselineTime_ms)
    % if we never turn the pump on, we can assume we're doing 
    % recirculation injection-style test (the pump turns on prior
    % to us collecting UWA data and never goes off and back on). In
    % this case, we can rely on the sample state for baselining.
    startBaselineTime_ms = times_ms(firstSampInd) - dwellTime_ms - baselineTime_ms; 
    endBaselineTime_ms = times_ms(firstSampInd) - dwellTime_ms; 
    % zero time is when the sample is introduced.
    zeroInd = firstSampInd;
    % need to confirm these aren't out of bounds
end
