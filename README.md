# AlignSTORM
Automated alignment of STORM images based on fiducial bead images.

This code allows the user to align single-molecule localization microscopy images, or STORM images (stochastic optical reconstruction microscopy)
by performing affine transformations on images of fiducial beads that correspond to each iterative image of a region of interest. 
The application I use it for is to correct for drift of the sample and microscope over many-hour imaging runs during which I iteratively image
the same regions of the sample multiple times.

Getting started
You will need bead images that correspond to each SMLM/STORM image, and to edit the file called Batch Alignment to enable the program to find 
your bead images and SMLM/STORM images.

You will also need a way to read your SMLM/STORM images into MATLAB. I use functions from ZhuangLab/matlab-storm, which this repository depends upon,
but any other method you use to get your data into a data structure in MATLAB will work.
