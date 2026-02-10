function s = salvusShiftFlowTime(s)
% salvusShiftFlowTime corrects for clock asyncronization between devices 
% capturing flow rate and unwrapped angle. presents a flowRate plot, queries 
% the user to select the point where flow is cut off (at the end of unwrapped 
% angle capture), and shifts the flow rate time vector to align with the 
% unwrapped angle time vector. 
% 
% Required: Install "Graphical data selection tool" by John D'Errico, 
% v1.0.0.0 from Mathworks file exchange

close all

for p = 1:length(s)
    if ~isempty(s(p).times_date_flow)
        fig = figure;
        fig.WindowState = 'maximized';
        plot(s(p).flowRate)
        ttl = title('Please select the point where flow is stopped (corresponds to last UWA sample)!');
        ttl.FontSize = 16;
        ylabel('Flow rate (uL/min)')
        xlabel('Sample index')
        [~, endInd, ~] = selectdata('Verify','on','Axes', gca,'SelectionMode','Closest','Label','on','Identify','on');
        
        % save the original to a new field
        s(p).times_date_flow_raw = s(p).times_date_flow;  
        
        % save the shifted array to the existing field
        s(p).times_date_flow = s(p).times_date_flow - s(p).times_date_flow(endInd) + s(p).times_date(end);
        close all
        disp(['Flow time array was shifted for ', num2str(s(p).filename)])
    elseif isempty(s(p).times_date_flow) && ~isempty(s(p).flowRate)
        s(p).times_date_flow = s(p).times_date;
        s(p).times_date_flow_raw = [];  
    else
        s(p).times_date_flow_raw = [];
    end
end