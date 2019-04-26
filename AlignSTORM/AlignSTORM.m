function [d] = AlignSTORM(filePath_STORM, tforms_affine, tforms_poly, d, line);

numbits = size(filePath_STORM,2);

d{line, 1} = ReadMasterMoleculeList(filePath_STORM{line, 1}); %first hyb 

for i=2:numbits;
    d{line, i} = ReadMasterMoleculeList(filePath_STORM{line, i}); %all other STORM images
    
    % Perform nonreflective similarity transform on the input channel and
    % output into x0t and y0t
    [x0t, y0t] = tforminv(tforms_affine{line, i}, double(d{line, i}.xc), double(d{line, i}.yc));
    logIndC = d{line,i}(:).c == 1;
    
    u2x=x0t;
    u2y=y0t; 
    d{line, i}(:).xc = u2x;
    d{line, i}(:).yc = u2y;
    logIndC = d{line,i}(:).c == 1;
    d{line, i}.c(logIndC) = i; % to make composite binary file for all imaging rounds
    
    figure();
    scatter(d{line, i}.xc, d{line, i}.yc,'b.'); hold on 
    scatter(d{line, 1}.xc, d{line, 1}.yc,'r.'); hold on
    daspect([1 1 1]);
    
    affStr = strrep(filePath_STORM{line, i},'.bin','_affine.bin')
    %cd '/Users/Monica/Dropbox/MATLAB' %for mac
    WriteMoleculeList(d{line, i}, affStr);
   
end

end

