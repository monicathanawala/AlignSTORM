function [filePath, filePath_STORM, d] = Batch_Alignment(drive, expt, varargin);
%drive = 'Z:';
%expt = '2018_09_25_A';
%cd 'D:\2019_01_17_A'
%cd '\\Nuc\d\2018_09_25_A'


cd 'C:\Users\Monica\Dropbox\MATLAB' %use this for windows
%cd '/Users/Monica/Dropbox/MATLAB' %use this line instead for mac

for i=1:nargin-2;
    mypath = fullfile(drive, expt, varargin{i}, '/');
    dir(fullfile(mypath, 'bead488*.bin'))
    beadfileList = dir(fullfile(mypath, 'bead488*.bin'))
    dir(fullfile(mypath, 'bead488*.bin'))
    STORMfileList = dir(fullfile(mypath, 'STORM647*list_dc.bin'));

    for i2=1:max(size(beadfileList));
        filePath{i2,i} = fullfile(mypath, beadfileList(i2).name);
        filePath_STORM{i2,i} = fullfile(mypath, STORMfileList(i2).name);
    end
    
end

cd 'C:\Users\Monica\Dropbox\MATLAB\AlignSTORM' %windows
%cd '/Users/Monica/Dropbox/MATLAB/AlignSTORM' %mac
BinaryBeadImage;
%this serves to get x and y shifts for all images and get affine transformation on bead images

d=struct([]);
for line=1:size(filePath_STORM, 1);
    [d] = AlignSTORM(filePath_STORM, tforms_affine, tforms_poly, d, line); %performs affine transformation from bead images on STORM images
end


end
