function salvus_save_results(s)

if isfield(s, 'RES_totalResponse')
    header = [];
    
    for c = 1:4
        header = [header, cellstr({['TotResp_Ch' num2str(c)]})];
        header = [header, cellstr({['Slope_Ch' num2str(c)]})];
        header = [header, cellstr({['R2_Slope_Ch' num2str(c)]})];
        header = [header, cellstr({['Baseline_Slope_Ch' num2str(c)]})];
        header = [header, cellstr({['R2_Baseline_Slope_Ch' num2str(c)]})];
    end
    
    mat = zeros(1, length(header)); 
    
    for p = 1:length(s)
        i=0;
        for c = 1:4
            i = i+1;
            mat(1,i) = s(p).RES_totalResponse(c); 
            i=i+1;
            mat(1,i) = s(p).RES_slope(c);
            i=i+1;
            mat(1,i) = s(p).RES_slopeRsq(c);
            i=i+1;
            mat(1,i) = s(p).BAS_slope(c);
            i=i+1;
            mat(1,i) = s(p).BAS_slopeRsq(c);
        end
        data = num2cell(mat);
        outCellMat = [header; data];
        newfilename = strcat(s(p).filename(1:end-4),'_results');
        newfilenamexlsx = strcat(newfilename,'.xlsx');
        writecell(outCellMat,newfilenamexlsx)
        disp(['Wrote results spreadsheet file, ' num2str(p), ' of ', num2str(length(s))])
    end
else
    disp('No results to write!')
end