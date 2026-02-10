function [Channel1_Name, Channel2_Name, Channel3_Name, Channel4_Name] = importSalvusChannelNames(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [CHANNEL1_NAME, CHANNEL2_NAME, CHANNEL3_NAME, CHANNEL4_NAME] =
%  IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the data as column vectors.
%
%  [CHANNEL1_NAME, CHANNEL2_NAME, CHANNEL3_NAME, CHANNEL4_NAME] =
%  IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  [Channel1_Name, Channel2_Name, Channel3_Name, Channel4_Name] = importfile("C:\Users\bethw\Desktop\bio\Salvus_DevPortal_Log_20220308_094623.txt", [5, 5]);
%
%  See also READTABLE.
%

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [5, 5];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 6);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Channel1_Name", "Channel2_Name", "Channel3_Name", "Channel4_Name", "Var5", "Var6"];
opts.SelectedVariableNames = ["Channel1_Name", "Channel2_Name", "Channel3_Name", "Channel4_Name"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Channel1_Name", "Channel2_Name", "Channel3_Name", "Channel4_Name", "Var5", "Var6"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Channel1_Name", "Channel2_Name", "Channel3_Name", "Channel4_Name", "Var5", "Var6"], "EmptyFieldRule", "auto");

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
Channel1_Name = tbl.Channel1_Name;
Channel2_Name = tbl.Channel2_Name;
Channel3_Name = tbl.Channel3_Name;
Channel4_Name = tbl.Channel4_Name;
end