function save_recomputed_logfile(s)
% Function save_best_UWA takes writes all recomputed/selected unwrapped angles
% in a structure array s and writes those arrays to an .xlsx file per log
% file stored in the structure array. 
% Salvus | Kickr Design | jacob@kickrdesign.com | 2022


for p=1:length(s)
    close all
    % for each element in the structure array (1 element per log file).
    
    % get the time vectors, fill NaN/missing values (sometimes at beginning
    % of vector), and convert the datetime format to string.
    times = s(p).times_ms;
    times = fillmissing(times, 'linear');
    times = times-times(1);
    times_date = datestr(fillmissing(s(p).times_date, 'linear'));
    data_rows = length(times_date);
    s(p).bufferStep = s(p).bufferStep(1:data_rows);
    s(p).sampleStep = s(p).sampleStep(1:data_rows);
    filler = ones(data_rows,1);
    mat = [times, s(p).times_s];
    cd = figure;
    for c=1:4
        % add in the selected unwrapped angles of the four channels.
        
        mat = [mat, s(p).uwa_rawsel{c}];
        
    end
    for c=1:4
        hold on
        mat = [mat, s(p).uwa_baseline_corrected{c}];
        plot(s(p).times_s, s(p).uwa_baseline_corrected{c},'Color', s(p).colors{c})
        xlabel('Time (s)'), ylabel('Baseline Corrected, iFreq autoSelected UWA (rad)')
        cd.Position = [200 200 1600 800];
        
        
    end
    yyaxis right
    zerosVec = zeros(1,length(s(p).times_s));
    baselineBounds = zerosVec;
    baselineBounds(s(p).baselineBoundsInd)=1;
    stem(s(p).times_s,baselineBounds,'Color','k','LineWidth',2,'Marker','none','LineStyle','--')
    hold on
    pumpOnTrans = zerosVec;
    pumpOnTrans(s(p).pumpOnTransitions)=1;
    pumpOffTrans = zerosVec;
    pumpOffTrans(s(p).pumpOffTransitions)=1;
    sampTrans = zerosVec;
    sampTrans(s(p).sampleTransitions)=1;
    stem(s(p).times_s,pumpOnTrans,'b','Marker','none','LineStyle','--')
    stem(s(p).times_s,pumpOffTrans,'g','Marker','none','LineStyle','--')
    stem(s(p).times_s,sampTrans,'r','Marker','none','LineStyle','--')
    ylim([.1 1])

    for c=1:4
        % add in the raw unwrapped angles of the four channels.
        mat = [mat, s(p).uwa_raw{c}];
    end
    for c=1:4
        % add in selected uwa with offset correction
        mat = [mat, s(p).uwa_sel_oc{c}];
    end
    for c=1:4
        % add in the SNR of the four channels
        mat = [mat, s(p).snr_sel{c}];
    end
    for c=1:4
        mat = [mat, filler.*(s(p).iFreq_selected(c))];
    end
    % add in the buffer and sample checkbox states, converting everything
    % to cell arrays so we can write the various formats to a spreadsheet.
    mat = [mat, s(p).bufferStep, s(p).sampleStep]; 
    
    if isfield(s,'uwa_long_bc')
        if ~isempty(s(p).uwa_long_bc)
            mat = [mat, s(p).uwa_long, s(p).uwa_long_bc];
        end
    end

    if isfield(s,'flowRateAligned')
        if ~isempty(s(p).flowRateAligned)
            mat = [mat, s(p).flowRateAligned, smoothdata(s(p).flowRateAligned,"movmean",[3*60*14.5, 0])];
        end
    end

    if isfield(s,'volume')
        if ~isempty(s(p).volume)
            mat = [mat, s(p).volume];
        end
    end

    for c=1:4
        mat = [mat, s(p).uwa_baseline_corrected{c}];
        
    end

    if isfield(s,'flowRateAligned')
        if ~isempty(s(p).flowRateAligned)
            mat = [mat, s(p).flowRateAligned];
        end
    end
    
    matcell = [cellstr(times_date), num2cell(mat)]; 
    % create a row of descriptive headers and add on top.
    headers = cellstr({'DateTime', 'Time (ms)', 'Time from Start (sec)', ...
        'UWA_Selected_1', 'UWA_Selected_2', 'UWA_Selected_3', 'UWA_Selected_4', ...
        'UWA_BaselineCorr_1', 'UWA_BaselineCorr_2','UWA_BaselineCorr_3', 'UWA_BaselineCorr_4', ...
        'UWA_RAW_1', 'UWA_RAW_2', 'UWA_RAW_3', 'UWA_RAW_4', ...
        'UWA_Sel_OC_1', 'UWA_Sel_OC_2', 'UWA_Sel_OC_3', 'UWA_Sel_OC_4', ...
        'SNR_Selected_1', 'SNR_Selected_2', 'SNR_Selected_3', 'SNR_Selected_4', ...
        'iFreq_selected_1','iFreq_selected_2','iFreq_selected_3','iFreq_selected_4', ...
        'bufferState', 'sampleState'});

    if isfield(s,'uwa_long_bc')
        if ~isempty(s(p).uwa_long_bc)
            headers = [headers, cellstr({'UWA_Long_Raw', 'UWA_Long_BaselineCorr'})];
        end
    end

    if isfield(s,'flowRateAligned')
        if ~isempty(s(p).flowRateAligned)
            headers = [headers, cellstr({'Flowrate (ul/min)'}), cellstr({'Mov Avg Flowrate (ul/min)'})];
        end
    end

    if isfield(s,'volume')
        if ~isempty(s(p).volume)
            headers = [headers, cellstr({'Volume (uL)'})];
        end
    end

    for c=1:4
        headers = [headers, cellstr({['UWA_BaselineCorr_' num2str(c)]})];
    end

    if isfield(s,'flowRateAligned')
        if ~isempty(s(p).flowRateAligned)
            headers = [headers, cellstr({'Flowrate (ul/min)'})];
        end
    end
 
    matcell = [headers; matcell];
    hold off
    % write the cell matrix to a file.
    filename = s(p).filename;
    newfilename = strcat(filename(1:end-4),'_recalc');
    grid on
    saveas(cd,newfilename,'png')

    if isfield(s,'uwa_long_bc')
        if ~isempty(s(p).uwa_long_bc)
            jt = figure; 
            plot(s(p).times_s, s(p).uwa_long_bc)
            xlim([-1000/15 13000/15])
            ylim([-20 80])
            grid on
            filepathname = s(p).filename; 
            slashes = find(filepathname=='\');
            Filename = filepathname((slashes(end)+1):end);
            title(['p = ', num2str(p), '; ', Filename],'Interpreter','none')
            ylabel('Unwrapped Angle (Radians), computed from combined ROI and baselined')
            xlabel('Time (s)')
            jt.WindowState = 'maximized';
            saveas(jt,strcat(newfilename(1:end-6), '_longuwabc'),'png')
        end
    end

    newfilenamexlsx = strcat(newfilename,'.xlsx');
    writecell(matcell,newfilenamexlsx)
    disp(['Wrote file ', num2str(p), ' of ', num2str(length(s)), ', ' newfilenamexlsx, ' to disk.'])
    close(cd)
end
disp('Finished writing recomputed log files.')
end