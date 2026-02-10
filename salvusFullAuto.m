% salvusFullAuto
% 

startTime = tic;
% outfilename = input(...
%     'Please enter a filename (as a string!) for the resulting structure array...');
s = salvusImportFolder(true); % set this true if new .csv, false if old .txt
close all

s = salvusMarkerTiming(s);
s = salvus_iFreq_postSelector_segment(s);
s = salvusOffsetCorr(s);
s = salvusShiftFlowTime(s);  % use with device UI to sync flow time
s = salvusAlignFlow(s);
s = salvusComputeResults(s,false,true);
s = salvusVolumeComputations(s,true); % remove "true" if no plot desired
s = salvus_Plot_iFreqs(s);
salvusJitterHistograms(s);
salvusMIJI;
salvusNormContrast_foundFringes(s,MIJ);
save_recomputed_logfile(s);
salvus_save_iFreqs(s); % saves one excel file per channel with all uwa @ iFreqs computed
salvus_save_results(s);
% save(outfilename, 's','-v7.3')
save('blips.mat')
endTime = toc(startTime);
disp(['All Salvus log files processed in ',  num2str(endTime/60), ' minutes.'])