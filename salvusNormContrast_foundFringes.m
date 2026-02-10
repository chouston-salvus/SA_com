function s = salvusNormContrast_foundFringes(s,MIJ)

salvusMIJI;
% javaaddpath 'C:\Program Files\MATLAB\R2023b\java\mij.jar';
% javaaddpath 'C:\Program Files\MATLAB\R2023b\java\ij.jar';
% MIJ.start("C:\Users\jacob\Downloads\fiji-win64\Fiji.app");

for p = 1:length(s)
    if ~isempty(s(p).foundFringes)
        imageTitle = ['foundFringes' num2str(p)];
        MIJ.createImage(imageTitle, s(p).foundFringes,true);
        MIJ.run("Normalize Local Contrast", "block_radius_x=40 block_radius_y=40 standard_deviations=3 center stretch");
        s(p).foundFringes_NLC = uint8(MIJ.getCurrentImage());
        MIJ.run("Close");
    end
end

MIJ.exit; 