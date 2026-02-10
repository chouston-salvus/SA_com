function [times_xx, pixPos_yy, fringe] = fringeSurf(s, p, c, plotTrue, longFringeTrue)
%Function fringeSurf plots a 3D surface representation of a selected fringe
%pattern 'fringe' over time 'times'. 

if nargin<5
    longFringeTrue = 0;
end

if nargin<4
    plotTrue=0;
end


if longFringeTrue==false
    fringe = s(p).fringe{c}(6:end,:); %CHOPPED for clarity
else
    fringe = s(p).longFringe;
end
times = s(p).times_ms(6:end)./(1000.*60); % time in minutes; CHOPPED for clarity

fringe = rmmissing(fringe);
[row, col] = size(fringe);
if row~=length(times)
    times = rmmissing(times);
end

[times_xx, pixPos_yy] = meshgrid(times, 1:col);

if plotTrue==1

    fsurf = figure(1);
    subplot(2,1,2)
    surf(pixPos_yy,times_xx,fringe')
    colormap('gray')
    shading interp
    view(90,270)
    xlabel('Pixel X-Position')
    ylabel('Time (min)')
    xlim([1 col])
    filepathname = s(p).filename; 
    slashes = find(filepathname=='\');
    Filename = filepathname((slashes(end)+1):end);
    title(['p = ', num2str(p), ', Channel = ', num2str(c), ', ' 'Width = ', num2str(col), '; ', Filename],'Interpreter','none')
%     fsurf.Position = [200 200 1000 600];
    fsurf.WindowState = 'maximized';
    filename = s(p).filename;
    newfilename = strcat(filename(1:end-4),'_',num2str(c),'_',num2str(col),'_fringeSurf');
    saveas(fsurf,newfilename,'png')
end