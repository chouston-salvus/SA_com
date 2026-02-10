function [Date_time, ChannelNum, Unwrapped_Angle, SNR, bufferState, sampleState] = importSalvusData(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [DATE_TIME, CHANNELNUM, UNWRAPPED_ANGLE, SNR, BUFFERSTATE,
%  SAMPLESTATE] = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as column
%  vectors.
%
%  [DATE_TIME, CHANNELNUM, UNWRAPPED_ANGLE, SNR, BUFFERSTATE,
%  SAMPLESTATE] = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  [Date_time, ChannelNum, Unwrapped_Angle, SNR, bufferState, sampleState] = importfile("C:\Users\bethw\Desktop\bio\Salvus_DevPortal_Log_20220308_094623.txt", [9, Inf]);
%
%  See also READTABLE.
%

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [4, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 6);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Date_time", "ChannelNum", "Unwrapped_Angle", "SNR", "bufferState", "sampleState"];
opts.VariableTypes = ["datetime", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "Date_time", "InputFormat", "yyyy/MM/dd HH:mm:ss.SSS");
opts = setvaropts(opts, ["ChannelNum", "Unwrapped_Angle", "SNR", "bufferState", "sampleState"], "ThousandsSeparator", ",");

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
Date_time = tbl.Date_time;
ChannelNum = tbl.ChannelNum;
Unwrapped_Angle = tbl.Unwrapped_Angle;
SNR = tbl.SNR;
bufferState = tbl.bufferState;
sampleState = tbl.sampleState;
end