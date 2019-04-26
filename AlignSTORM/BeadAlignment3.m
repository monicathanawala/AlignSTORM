function [c1_unique, c2_unique, ix, iy, tform_0inv] = BeadAlignment3(c, i, initxshift, inityshift);
%ix, iy, tx, ty, tform, tform2, tform3, 
%--------------------------------------------------------------------------
% 06/05/2016 Monica Thanawala
% adapted from Sang-Hee Shim's code 'MapBeadWarp3D.m'

%I made significant changes to this code on 8/18/2017. Now, it is more
%adaptable in that it can handle beads showing up in one channel but not
%the other. It's used for sub-pixel bead alignment.

%This function takes a single bead image (image i in struct c) and uses the
%initial x and y shifts calculated by BinaryBead image to get a starting
%point for the next transforms.

%I made more changes on 12/1/17. Now, I do a nonreflective similarity
%transform instead of a polynomial warp, since it's all A647 imaging. I
%commented out the polynomial warp step. In the future if this is used for
%true multi-color imaging, the nonreflective similarity transform should be
%used for drift correction, then the polynomial warp for chromatic
%aberration correction.

%changes on 2/11/2019 to look for z-mismatch.
%--------------------------------------------------------------------------

tolxy = 1; % tolerance (disparity) in xy between the two channels, in pixels
samebead = 0.3; % pixel distance between two localizations for them to likely be the same bead
 
c1_good = find(c{1}.x>0); 
c2_good = find(c{i}.x>0); 

N1 = size(c1_good,1);
N2 = size(c2_good,1);

c1log = true(length(c1_good), 1);
c2log = true(length(c2_good), 1);


for n = 1:N1;
    allc1 = c1_good(n);
    close_c1 = find(abs(c{1}.x(n)-c{1}.x)<samebead); %& abs(c1.y(n)-c1.y)<samebead);
    if length(close_c1)>1 & c1log(n)==1;
        avgxpos = mean(c{1}.x(close_c1)); %find the average x position of this bead
        avgypos = mean(c{1}.y(close_c1)); %average y position
        avgzpos = mean(c{1}.z(close_c1)); %average z position
        c1.x(n) = avgxpos; %set the localization at position n to the avg x pos
        c1.y(n) = avgypos; %set the localization at position n to the avg y pos
        c1.z(n) = avgzpos; %set the localization at position n to the avg z pos
        for n2=2:length(close_c1);
            c1log(close_c1(n2),1)=0; %fill in 0 to logical for all other locs for later deletion
        end
    end
end

 for n = 1:N2;
    allc2 = c2_good(n);
    close_c2 = find(abs(c{i}.x(n)-c{i}.x)<samebead); %& abs(c2.y(n)-c2.y)<samebead);
    if length(close_c2)>1;
        avgxpos = mean(c{i}.x(close_c2)); %find the average x position of this bead
        avgypos = mean(c{i}.y(close_c2)); %find the average y position 
        avgzpos = mean(c{i}.z(close_c2)); %find the average z position 
        c{i}.x(n) = avgxpos; %set the localization at position n to the avg x pos
        c{i}.y(n) = avgypos; %set the localization at position n to the avg y pos
        c{i}.z(n) = avgzpos; %set the localization at position n to the avg z pos
        for n2=2:length(close_c2);
            c2log(close_c2(n2),1)=0; %fill in 0 to logical for all other locs for later deletion
        end
    end
 end


c1_unique = subsetstruct(c{1}, c1log);
c2_unique = subsetstruct(c{i}, c2log);
c1_good(~c1log,:) = []; 
c2_good(~c2log,:) = [];

%show whether initxshift and inityshift got good initial matching
figure();
scatter(c1_unique.x, c1_unique.y, 'r.'); hold on
scatter(c2_unique.x - initxshift, c2_unique.y - inityshift, 'g.');
legend('unique c1','unique c2 shifted');
daspect([1 1 1]);

i2 = 1;
for n = 1:length(c2_unique.x);
    m = find(abs([c1_unique.x]-([c2_unique.x(n)]-initxshift))<tolxy & abs([c1_unique.y]-([c2_unique.y(n)]-inityshift))<tolxy);
    if (size(m,1)==1)
        ix(i2) = c2_unique.x(n);
        iy(i2) = c2_unique.y(n);
        iz(i2) = c2_unique.z(n);
        
        bx(i2) = c1_unique.x(m);  
        by(i2) = c1_unique.y(m);
        bz(i2) = c1_unique.z(m);
        i2=i2+1;
    end
end

% at this point the bead lists should be matched and about the same length
% b corresponds to base, or channel1
% i corresponds to input, or channel2

ix = double(ix);
iy = double(iy);
iz = double(iz);
bx = double(bx);
by = double(by);
bz = double(bz);

%Warping in 2D
input = [ ix' iy']; % input (c2)
base = [ bx' by']; % base (c1)

poly_order = 2;
method = 'nonreflective similarity';

tform_0 = cp2tform(input, base, method); % compute warp
tform_0inv = cp2tform(base, input, method); % compute warp
  
% Perform nonreflective similarity transform on the input channel and
% output into x0t and y0t, then input_nrs
%[x0t, y0t] = tforminv(tform_0inv, ix, iy); changed 1/7
[x0t, y0t] = tforminv(tform_0inv, ix, iy);
input_nrs = [ x0t' y0t']; 

figure();
scatter(x0t, y0t, 'b.'); hold on
scatter(ix, iy, 'ko'); hold on
scatter(bx, by, 'r.'); hold on
legend('nrs transformed c2','original c2', 'original c1');
daspect([1 1 1]);

end 
