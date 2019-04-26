%this script serves to:
% -read in the bead images described in filePath,
% -make binary images of the beads' xy positions (divide image into
% subpixels)
% -get cross correlation between two images to figure out initial x and y
% shifts
% -do bead alignment to get transform from c{1} to c{n} via BeadAlignment3
% -output the tforms (affine and poly) for each bit into tforms cell array

for line=1:size(filePath,1);
    numbits = size(d,2); 
    cd /Users/monica/Dropbox/MATLAB %mac
    c{1} = ReadMasterMoleculeList(filePath{line, 1}); %reference bead image

    for i=1:numbits
        c{i} = ReadMasterMoleculeList(filePath{line, i}); %all other bead images
    end

    % make binary image of xy bead positions
    nsp = 1; %10 subpixels per pixel for 256x256 image
    I2 = zeros(256*nsp,256*nsp,5); %make image with right number of pixels
    for n=1:numbits;
        for i=1:length(c{n}.x);
            xpix = round((c{n}.x(i))*nsp); %assign bead x position to a pixel with 10 pixels per camera pixel
            ypix = round((c{n}.y(i))*nsp); %assign bead y position to a pixel with 10 pixels per camera pixel
            I2(xpix, ypix, n)=I2(xpix, ypix, n)+1;
        end
    end

    %get cross-correlation to figure out initial x and y shifts
    for n=2:numbits
        cc = xcorr2(I2(:,:,1),I2(:,:,n));
        %figure, surf(cc), shading flat
    [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));
        corr_offset = ([(ypeak-size(I2(:,:,1),1)) (xpeak-size(I2(:,:,1),2))])/nsp;
        initxshift=-1*corr_offset(1);
        inityshift=-1*corr_offset(2);
  
        [c1_unique, c2_unique,ix,iy, tform_0inv] = BeadAlignment3(c, n, initxshift, inityshift);
          tforms_affine{line, n}=tform_0inv;
          tforms_poly = 1;    
    end   
end


    
    
