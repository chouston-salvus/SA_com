function s = salvusAlignFlow(s)
% salvusAlignFlow populates a vector sampled at a faster rate with flow
% rate values sampled at a slower rate based on the match between the time
% vectors. This requires salvusShiftFlowTime to be run if the clocks are
% not synced (between the device capturing unwrapped angle and the device 
% capturing flow rate). 

for p = 1:length(s)

    % make sure there is data in the flow time field
    if ~isempty(s(p).times_date_flow)

        % initialize a NaN vector the size of the uwa times date array
        nearestInd = nan(size(s(p).times_date));

        % get the flow time vector
        fDt = s(p).times_date_flow;
    
        % set the flow rate values to the nearest uwa times times
        for i = 1:length(s(p).times_date)
            [~, nearestInd(i)] = min(abs(fDt - s(p).times_date(i)));
        end
    
        s(p).flowRateAligned = s(p).flowRate(nearestInd); 
        disp(['Aligned flow rate data file ' num2str(p) ' of ' num2str(length(s))])
    end
end