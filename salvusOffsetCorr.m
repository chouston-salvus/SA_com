function s = salvusOffsetCorr(s)

for p=1:length(s)  
    if ~isempty(s(p).sampleTransitions)
        firstSampInd = s(p).sampleTransitions(1); 
        for c=1:4
            s(p).uwa_sel_oc{c} = s(p).uwa_rawsel{c} - s(p).uwa_rawsel{c}(firstSampInd);
            disp(['Offset Corrected at first sample transition, file: ', num2str(p), ' of ', num2str(length(s)), ', channel ', num2str(c), '.'])
        end
    else
        for c=1:4
            s(p).uwa_sel_oc{c} = s(p).uwa_rawsel{c} - s(p).uwa_rawsel{c}(1);
            disp(['Offset Corrected using first timepoint, file: ', num2str(p), ' of ', num2str(length(s)), ', channel ', num2str(c), '.'])
        end
    end
end
        
    