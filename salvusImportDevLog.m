function s = salvusImportDevLog(filename, plotOption, csvTrue)
% Salvus | Kickr Design | jacob@kickrdesign.com | 2022

if nargin == 1
    plotOption = false; 
    csvTrue = false; 
end

stack = 3;

cd shortlongpathname\
slashlocs = strfind(filename,'\');
file = filename(slashlocs(end):end);
shortpath = filename(1:slashlocs(end));
shortened = getShortPath(shortpath);
s.filename = [shortened, file(2:end)];
cd ..\

s.filename_long = filename; 
if csvTrue == true
    opts = detectImportOptions(filename,'Delimiter',',','VariableNamesLine',7);
    opts.DataLines = [18 inf];
    ts = readtable(filename,opts,'ReadVariableNames',true);
    ts = ts(1:end-1,:);
    headers = string(ts.Properties.VariableNames);
    [ts, headers] = salvusRemoveColumns(ts,headers,'xtra');
%     [ts, headers] = salvusRemoveColumns(ts,headers,'Temp_'); %Todo: write different fxn to handle temperature extraction
    mat = table2array(ts);
    fillmethod = 'nearest';
    s.uwa_raw{1} = fillmissing(salvusHeaderMatcher(mat,headers,'UWA_1'),fillmethod);
    s.uwa_raw{2} = fillmissing(salvusHeaderMatcher(mat,headers,'UWA_2'),fillmethod);
    s.uwa_raw{3} = fillmissing(salvusHeaderMatcher(mat,headers,'UWA_3'),fillmethod);
    s.uwa_raw{4} = fillmissing(salvusHeaderMatcher(mat,headers,'UWA_4'),fillmethod);
    s.snr{1} = fillmissing(salvusHeaderMatcher(mat,headers,'SNR_1'),fillmethod);
    s.snr{2} = fillmissing(salvusHeaderMatcher(mat,headers,'SNR_2'),fillmethod);
    s.snr{3} = fillmissing(salvusHeaderMatcher(mat,headers,'SNR_3'),fillmethod);
    s.snr{4} = fillmissing(salvusHeaderMatcher(mat,headers,'SNR_4'),fillmethod);
    s.fringe{1} = fillmissing(salvusHeaderMatcher(mat,headers,'fringe_1'),fillmethod);
    s.fringe{2} = fillmissing(salvusHeaderMatcher(mat,headers,'fringe_2'),fillmethod);
    s.fringe{3} = fillmissing(salvusHeaderMatcher(mat,headers,'fringe_3'),fillmethod);
    s.fringe{4} = fillmissing(salvusHeaderMatcher(mat,headers,'fringe_4'),fillmethod);
    s.flowRate = fillmissing(salvusHeaderMatcher(mat,headers,'FlowRate'),fillmethod); %ml/min
    s.flowRateAligned = s.flowRate; % if we actually get something here we know it's already aligned
    s.fringe{1}(abs(s.fringe{1}) < 1e-20) = 0;
    s.fringe{2}(abs(s.fringe{2}) < 1e-20) = 0;
    s.fringe{3}(abs(s.fringe{3}) < 1e-20) = 0;
    s.fringe{4}(abs(s.fringe{4}) < 1e-20) = 0;
    s.bufferStep = salvusHeaderMatcher(mat,headers,'pumpState');
    s.sampleStep = salvusHeaderMatcher(mat,headers,'sampleState');
    for d = 1:5
        s.temp{d} = salvusHeaderMatcher(mat,headers,['Temp_Ch', num2str(d-1)]);
    end
    s.times_ms = mat(:,1)-mat(1,1);
    if strcmp(s.filename_long((end-6):(end-4)),'log')
        ie = ['20', s.filename_long(slashlocs(end)+1:slashlocs(end)+13)];
    else
        ie = s.filename_long(end-18:end-4);
    end

    epoch = [ie(1:4), '-', ie(5:6), '-', ie(7:8), ' ', ie(10:11), ':', ie(12:13), ':', ie(14:15)];

    if strcmp(s.filename_long((end-8):(end-4)),'_dlog')
        EST_offset = 5 * 60 * 60 *1000; % 5 hours * 60 minutes/hr * 60 seconds/min * 1000 ms / sec
        orig_time_calc = s.times_ms - EST_offset;
        originalTime = datetime(orig_time_calc/1000,'ConvertFrom','epochtime','Epoch', epoch,'InputFormat','SSS','Format','yyyy/MM/dd HH:mm:ss.SSS');
    else
        originalTime = datetime(s.times_ms/1000,'ConvertFrom','epochtime','Epoch', epoch,'InputFormat','SSS','Format','yyyy/MM/dd HH:mm:ss.SSS');
    end
    
    % datetime correction
    time_PC_0_fullstr = getBestDateTime(filename);
    time_PC_0_str = time_PC_0_fullstr{1,1}(25:end); % assumes leading text is 'Data logging started at '
    infmt = 'yyyy/MM/dd HH:mm:ss.SSS';
    time_PC_0 = datetime(time_PC_0_str,'InputFormat',infmt);
    offset = originalTime(1) - time_PC_0; 
    dtr = originalTime - offset;
    s.times_date = dtr; 

    % / datetime correction

    times_ms = s.times_ms; 
    s.times_date_flow = []; % pre-allocate fields
    %s.flowRate = [];
else
    fringeMat = importFringeMat(filename);
    [s.Channel1_Name, s.Channel2_Name, s.Channel3_Name, s.Channel4_Name] = importSalvusChannelNames(filename);
    [date_time, ChannelNum, Unwrapped_Angle, SNR, bufferState, sampleState] = importSalvusData(filename);
    ch1i = find(ChannelNum==1);
    ch2i = find(ChannelNum==2);
    ch3i = find(ChannelNum==3);
    ch4i = find(ChannelNum==4);
    times_date = date_time(ch2i);
    s.bufferStep = bufferState(ch1i);
    s.sampleStep = sampleState(ch1i); 
    uwa1 = Unwrapped_Angle(ch1i);
    uwa2 = Unwrapped_Angle(ch2i);
    uwa3 = Unwrapped_Angle(ch3i);
    uwa4 = Unwrapped_Angle(ch4i);
    snr1 = SNR(ch1i);
    snr2 = SNR(ch2i);
    snr3 = SNR(ch3i);
    snr4 = SNR(ch4i);
    n = min([length(uwa1) length(uwa2) length(uwa3) length(uwa4)]);
    s.uwa_raw{1} = uwa1(1:n);
    s.uwa_raw{2} = uwa2(1:n);
    s.uwa_raw{3} = uwa3(1:n);
    s.uwa_raw{4} = uwa4(1:n);
    s.snr{1} = snr1(1:n);
    s.snr{2} = snr2(1:n);
    s.snr{3} = snr3(1:n);
    s.snr{4} = snr4(1:n);
    s.times_date = times_date(1:n);
    fringe1 = fringeMat(ch1i,:);
    fringe2 = fringeMat(ch2i,:);
    fringe3 = fringeMat(ch3i,:);
    fringe4 = fringeMat(ch4i,:);
    s.fringe{1} = fringe1(1:n,:);
    s.fringe{2} = fringe2(1:n,:);
    s.fringe{3} = fringe3(1:n,:);
    s.fringe{4} = fringe4(1:n,:);

end

fs = 15; % approximate sampling rate (Hz)
t_smooth = 20;   % smooth span in seconds
if csvTrue == 0
    times_ms = milliseconds(times_date - times_date(2));
end

% Transition calculations
s.bufferTransitions = find(diff(s.bufferStep) ~= 0);
s.pumpOnTransitions = find(diff(s.bufferStep)>0);
s.pumpOffTransitions = find(diff(s.bufferStep)<0);
bufferOnes = ones(length(times_ms),1); 
s.sampleTransitions = find(diff(s.sampleStep) ~= 0);
sampleOnes = ones(length(times_ms),1); 
s.buffStem = bufferOnes(s.bufferTransitions);
s.sampStem = sampleOnes(s.sampleTransitions);

% Jitter calculations

% s.times_ms = times_ms(1:n);
jitt = milliseconds(diff(times_ms));
jitt(jitt==0)=[];
jitt(milliseconds(jitt)>1000)=[];
s.timing_stats.jitter = fillmissing(milliseconds(jitt),'linear');
% disp('hello')
jitter_tr = s.timing_stats.jitter(4:end-1);
s.timing_stats.dT_min = min(jitter_tr);
s.timing_stats.dT_max = max(jitter_tr);
s.timing_stats.dT_mean = mean(jitter_tr);
s.timing_stats.dT_stdev = std(jitter_tr);  
s.timing_stats.dT_med = median(jitter_tr);
s.timing_stats.dT_mode = mode(jitter_tr);
ddt = diff(jitt(6:end-1));
transitions = (ddt~=0);
ftrans = find(transitions==1);
% missingData = diff(ftrans);

if (plotOption == true)
    times_s = s.times_ms/1000;
    % set up colors
    c1c = 1/255*[255 0 0];
    c2c = 1/255*[0 255 0];
    c3c = 1/255*[0 0 255];
    c4c = 1/255*[0 156 222];
    cbc = 1/255*[137 52 235];
    csc = 1/255*[235 137 52];
    s.colors{1}=c1c;
    s.colors{2}=c2c;
    s.colors{3}=c3c;
    s.colors{4}=c4c;
    s.foundFringes = [];
    s.afterInitialAGC = [];
    s.afterAffAgc = [];
    s.ap = [];
    % set up the new figure
    uf = figure;
    
    % Plot the Unwrapped Angles
    subplot(stack,1,1)
    yyaxis left
    plot(times_s, s.uwa_raw{1}, '-', 'color', c1c, 'LineWidth', 1.5)
    hold on
    plot(times_s, s.uwa_raw{2}, '-', 'color', c2c, 'LineWidth', 1.5)
    plot(times_s, s.uwa_raw{3}, '-', 'color', c3c, 'LineWidth', 1.5)
    plot(times_s, s.uwa_raw{4}, '-', 'color', c4c, 'LineWidth', 1.5)
    uf.Color = [1 1 1];
    uf.Position = [200 200 1600 800];
    ylabel('Unwrapped Phase (radians)')
    title(filename,'Interpreter','none')
    yyaxis right
    stem(times_s(s.bufferTransitions),s.buffStem, '--', 'Color', cbc, 'Marker','none')
    stem(times_s(s.sampleTransitions),s.sampStem, '--', 'Color', csc, 'Marker','none')
    % legend([strcat('Ch1:  ', Channel1_Name), strcat('Ch2:  ', Channel2_Name), strcat('Ch3:  ', Channel3_Name), strcat('Ch4:  ', Channel4_Name), 'Buffer Transition', 'Sample Transition'], 'Location', 'eastoutside')
    set(gca, 'YTick', [])
    
    % Plot the SNRs
    sf = subplot(stack,1,2);
    yyaxis left
    plot(times_s, smoothdata(s.snr{1}, 'movmean', (fs*t_smooth)), '-', 'color', c1c, 'LineWidth', 1.5)
    hold on
    plot(times_s, smoothdata(s.snr{2}, 'movmean',(fs*t_smooth)), '-', 'color', c2c, 'LineWidth', 1.5)
    plot(times_s, smoothdata(s.snr{3}, 'movmean', (fs*t_smooth)), '-', 'color', c3c, 'LineWidth', 1.5)
    plot(times_s, smoothdata(s.snr{4}, 'movmean', (fs*t_smooth)), '-', 'color', c4c, 'LineWidth', 1.5)
    set(gca, 'YScale', 'log')
    ylim([1 1000])
    sf.Color = [1 1 1];
    xlabel('Time (sec)')
    ylabel('SNR')
    yyaxis right
    stem(times_s(s.bufferTransitions),s.buffStem, '--', 'Color', cbc, 'Marker','none')
    stem(times_s(s.sampleTransitions),s.sampStem, '--', 'Color', csc, 'Marker','none')
    % legend([strcat('Ch1:  ', Channel1_Name), strcat('Ch2:  ', Channel2_Name), strcat('Ch3:  ', Channel3_Name), strcat('Ch4:  ', Channel4_Name), 'Buffer Transition', 'Sample Transition'], 'Location', 'eastoutside')
    set(gca, 'YTick', [])
    
    % Plot Jitter
    tf = subplot(stack, 1, 3);
    yyaxis left
    plot(jitter_tr)
    ylim([0 100])
    ylabel('diff(time) (milliseconds)')
%     hold on
%     yyaxis right
%     stem(4-missingData, 'r')
%     ylabel('estimated skipped lines')
%     ylim([0 5])
    xlabel('Time (milliseconds)')
    saveas(gcf, strcat(s.filename(1:end-4), '.png'))
    saveas(gcf, strcat(s.filename(1:end-4), '.fig'))
    

end