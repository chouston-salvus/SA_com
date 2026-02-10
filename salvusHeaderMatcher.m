function outputArray = salvusHeaderMatcher(inputArray, headersString, matchString)
% The salvusHeaderMatcher function takes in an input array converted from
% an imported table, a header string from the imported table, along with a
% string specifying which header data is to be saved in the outputArray. 

[r, c] = size(inputArray);
detected = contains(headersString, matchString); % 
ind = find(abs(diff(detected))); %
if isempty(ind)
    outputArray = NaN(r,1); %
elseif length(ind)<2
    ind(2) = c;
    outputArray = inputArray(:,(ind(1)+1):ind(2)); %
else
    outputArray = inputArray(:,(ind(1)+1):ind(2)); %
end


end