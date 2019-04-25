function [d] = AlignSTORM(filePath_STORM, tforms_affine, tforms_poly, d, line);

i=1;
numbits = 5; %changed 2/1

d{line, 1} = ReadMasterMoleculeList(filePath_STORM{line, 1}); %first hyb 

for i=2:numbits;
    d{line, i} = ReadMasterMoleculeList(filePath_STORM{line, i}); %all other STORM images
    
    % Perform nonreflective similarity transform on the input channel and
    % output into x0t and y0t
    %[x0t, y0t] = tforminv(tforms_affine{line, i}, double(d{line, i}.x), double(d{line, i}.y));
    [x0t, y0t] = tforminv(tforms_affine{line, i}, double(d{line, i}.xc), double(d{line, i}.yc));
    logIndC = d{line,i}(:).c == 1;
    
    %[u2x, u2y] = tforminv(tforms{i}, double(x0t), double(y0t));
    u2x=x0t;
    u2y=y0t; 
    %d{i}(:).xct = u2x;
    %d{i}(:).yct = u2y;
    d{line, i}(:).xc = u2x;
    d{line, i}(:).yc = u2y;
    logIndC = d{line,i}(:).c == 1;
    d{line, i}.c(logIndC) = i; %new 5/29/2018 to make composite bin file
    
    figure();
    %scatter(d{i}.xct, d{i}.yct,'b.'); hold on
    scatter(d{line, i}.xc, d{line, i}.yc,'b.'); hold on  
    %scatter(d{i}.xc, d{i}.yc,'k.'); hold on
    scatter(d{line, 1}.xc, d{line, 1}.yc,'r.'); hold on
    daspect([1 1 1]);
    
    affStr = strrep(filePath_STORM{line, i},'.bin','_affine.bin')
    %cd '/Users/Monica/Dropbox/MATLAB' % cannot get files to write onto
    %external hard drive on my macbook air! Not sure why, am using
    %/Volumes/Monica8 as the location.
    WriteMoleculeList(d{line, i}, affStr);
   
end

combinedMList{line} = [d{line, 1},d{line, 2}, d{line,3}, d{line,4}, d{line,5}];

end

