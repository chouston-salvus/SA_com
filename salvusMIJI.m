% salvusMIJI
% need to have copied over the mij.jar and ij.jar to your Matlab
% installation's Java directory, update these paths, and the path to the
% Fiji installation. 

if ~(exist('MIJ')==8) % check if MIJ doesn't already exist as a class (Java)
    javaaddpath 'C:\Program Files\MATLAB\R2023b\java\mij.jar';
    javaaddpath 'C:\Program Files\MATLAB\R2023b\java\ij.jar';
    MIJ.start("C:\Users\jacob\Downloads\fiji-win64\Fiji.app");
    disp('MIJI started... use MIJ.exit to quit.')
else
    disp('MIJI already started...')
end