function s = salvusVolumeComputations(s, plotTrue)

if nargin<2
    plotTrue = false;
end

for p = 1:length(s)
    if ~isempty(s(p).times_date_flow) && ~(isempty(s(p).sampleTransitions))
        flowRate = s(p).flowRateAligned/60;  % originally uL/min; div by 60 to get uL/sec
        time = s(p).times_s; % time in seconds
        volume = cumtrapz(time,flowRate); % using a cumulative trapezoidal 
        % integration method to calculate volume based on flow rate and
        % time intervals

        % zero volume at the first sample transitions(1))
        s(p).volume = volume - volume(s(p).sampleTransitions(1));

        if plotTrue
            nfs = figure; 
            subplot(3,1,1)
            plot(time,volume)
            title(s(p).filename,'Interpreter','none')
            xlabel('Times (s)')
            ylabel('Volume (uL)')
    
            subplot(3,1,2)
            for c=1:4
                hold on
                plot(volume, s(p).uwa_baseline_corrected{c},'color',s(p).colors{c})
            end
            xlabel('Volume (uL)')
            ylabel('UWA_BC (rad)')
            hold off
    
            subplot(3,1,3)
            plot(time, s(p).flowRateAligned)
            xlabel('Time (s)')
            ylabel('Flow Rate (uL/min)')

            nfs.WindowState = 'maximized';
            saveas(nfs, strcat([s(p).filename(1:end-4), '_flows'], '.png'))
        end
    else
        s(p).volume = [];

    end
end

