function s = salvusImportFolder(csvTrue)

if csvTrue == true
    extension = '*.csv';
else
    extension = '*.txt';
end

filedir = uigetdir;
folderFiles = dir(fullfile(filedir,['**\', extension]));
folderFiles = folderFiles(~[folderFiles.isdir]);

for i = 1:length(folderFiles)
    filename = fullfile(folderFiles(i).folder, folderFiles(i).name);
    
    
    opts = detectImportOptions(filename,'Delimiter',',','VariableNamesLine',7);
    opts.DataLines = [18 inf];
    if contains(filename,'_dlog.csv')
    %if ~contains(filename,'defaultData') && ~contains(filename,'updated_uwa') && ~contains(filename,'assayData') && ~contains(filename,'concentration_algo') && ~contains(filename,'deviceData')
        if isempty(strfind(opts.VariableNames{4},'FST_'))
            disp(filename)
            s(i) = salvusImportDevLog(filename, true, csvTrue);
            
            disp(['Imported DevLog file:  ', s(i).filename_long, ' L=' num2str(length(s(i).filename_long))])
            
            % for each file without the 'FST_' header, look in the same folder
            % for the matching file with the 'FST_' header. Then subsequently
            % import that and save the datetime and flow columns to the
            % matching element in the structure array. 
            currFolder = folderFiles(i).folder;
            currDirFiles = ls(currFolder);
            [rows,~] = size(currDirFiles);
            z=1;
            q=false;
            % if the analyzer didn't save flow data, look for the Dolomite-generated flow file
            if isnan(s(i).flowRate)
                while z <= rows
                    foundDash = strfind(currDirFiles(z,:),'-');
                    if length(foundDash)<2
                        z = z+1;
                    elseif (foundDash(1)==5)&&(foundDash(2)==8)
                        fullFlowFile = fullfile(folderFiles(i).folder,currDirFiles(z,:));
                        z = rows+1;
                        q = true;
                    else
                        z = z+1;
                    end
                end
                if q == true
                    [s(i).times_date_flow, s(i).flowRate] = importFlowCSV(fullFlowFile);
                    disp(['Imported Flow file: ', fullFlowFile])

                end
            end
            % look for images
            z=1;
            while z<=rows
                if contains(currDirFiles(z,:),'.bmp') || contains(currDirFiles(z,:),'.log')
                    if contains(currDirFiles(z,:),'foundFringes')
                        s(i).foundFringes = imread(fullfile(folderFiles(i).folder,currDirFiles(z,:)));
                    end
                    if contains(currDirFiles(z,:),'afterInitialAgc')
                        s(i).afterInitialAGC = imread(fullfile(folderFiles(i).folder,currDirFiles(z,:)));
                    end
                    if contains(currDirFiles(z,:),'afterAffAgc')
                        s(i).afterAffAgc = imread(fullfile(folderFiles(i).folder,currDirFiles(z,:)));
                    end
                    if contains(currDirFiles(z,:),'assayParameters.log')
                        strArray = salvusImportAssayParams(fullfile(folderFiles(i).folder,currDirFiles(z,:)));
                        s(i).ap.threshold = str2double(strArray((contains(strArray,'Threshold')),2));
                        s(i).ap.analyte = strArray((contains(strArray,'Analyte')),2);
                        s(i).ap.ui_result = strArray((contains(strArray,'Calculated Result')),2);
                        s(i).ap.waveguide = strArray((contains(strArray,'Waveguide')),2);
                        s(i).ap.MinBuffCircTime = str2double(strArray(contains(strArray,'MinBuffCircTime'),2));
                        if isempty(s(i).ap.MinBuffCircTime)
                            s(i).ap.MinBuffCircTime = str2double(strArray(contains(strArray,'Minimum Buffer Circulation Time'),2));
                        end
                        s(i).ap.BaselineStableTime = str2double(strArray(contains(strArray,'BaselineStableTime'),2));
                        if isempty(s(i).ap.BaselineStableTime)
                            s(i).ap.BaselineStableTime = str2double(strArray(contains(strArray,'Baseline Stablility Time'),2));
                        end
                        s(i).ap.SampleToMeasStartTime = str2double(strArray(contains(strArray,'SampleToMeasStartTime'),2));
                        if isempty(s(i).ap.SampleToMeasStartTime)
                            s(i).ap.SampleToMeasStartTime = str2double(strArray(contains(strArray,'Sample To Measure Start Time'),2));
                        end
                        s(i).ap.SampleRunTime = str2double(strArray(contains(strArray,'SampleRunTime'),2));
                        if isempty(s(i).ap.SampleRunTime)
                            s(i).ap.SampleRunTime = str2double(strArray(contains(strArray,'Sample Run Time'),2));
                        end
                        s(i).ap.BaselineTime = str2double(strArray(contains(strArray,'BaselineTime'),2));
                        if isempty(s(i).ap.BaselineTime)
                            s(i).ap.BaselineTime = str2double(strArray(contains(strArray,'Baseline Time'),2));
                        end
                        s(i).ap.ExtraSampleTime = str2double(strArray(contains(strArray,'ExtraSampleTime'),2));
                        if isempty(s(i).ap.ExtraSampleTime)
                            s(i).ap.ExtraSampleTime = str2double(strArray(contains(strArray,'Extra Sample Time'),2));
                        end
                        s(i).ap.RunningBufferFlushTime = str2double(strArray(contains(strArray,'RunningBufferFlushTime'),2));
                        if isempty(s(i).ap.RunningBufferFlushTime)
                            s(i).ap.RunningBufferFlushTime = str2double(strArray(contains(strArray,'Running Buffer Flush Time'),2));
                        end
                    end
                end

                z=z+1;
            end
    
    
        else
    
        end
    end
end

for p = 1:length(s)
    indLog(p) = isempty(s(p).filename);
end

s(indLog) = [];
