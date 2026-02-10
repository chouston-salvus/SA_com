function [ts, headerString] = salvusRemoveColumns(ts, headerString, matchString)
% The salvusHeaderMatcher function takes in an input array converted from
% an imported table, a header string from the imported table, along with a
% string specifying which header data is to be saved in the outputArray. 

detected = contains(headerString, matchString); % 
ts(:,detected)=[];
headerString(detected)=[];

end