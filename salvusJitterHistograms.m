function s = salvusJitterHistograms(s)

for p=1:length(s)
    jitt = figure;
    histo = histogram(s(p).timing_stats.jitter);
    hold on
    binEdges = histo.BinEdges(histo.Values>0); 
    values = histo.Values(histo.Values>0);
    plot(binEdges, values,'r*')
    ylabel('Count')
    xlabel('Time between samples (milliseconds)')
    title('Sample Period Histogram')
    str = {};
    for i = 1:length(values)
        str{i} = [num2str(values(i)) ', ' num2str(binEdges(i))];
    end
    text(binEdges, values, str)
    s(p).timing_stats.histoValues = values;
    s(p).timing_stats.histoBinEdges = binEdges;
    newfilename = strcat(s(p).filename(1:end-4),'_jitter');
    saveas(jitt, newfilename , 'png')
    close(jitt)
end
disp('Saved jitter histograms.')