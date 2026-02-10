function salvus_save_iFreqs(s)

iFreq_start = 10;
iFreq_end = 14;

for p=1:length(s)
    [~, col] = size(s(p).uwa_at_iFreq);
    for c=1:4
        mat = [];
        header = [];
        for f=1:col
            if ~isempty(s(p).uwa_at_iFreq{c,f})
                header = [header, {strcat('iFreq= ', num2str(f))}];
                mat = [mat, s(p).uwa_at_iFreq{c,f}];
            end
        end
        matcell = [header; num2cell(mat)];
        filename = s(p).filename;
        newfilename = strcat(filename(1:end-4),'_iFreq_ch',num2str(c),'.xlsx');
        writecell(matcell,newfilename);
        disp(['Wrote file ', newfilename, ' to disk.'])
    end
end