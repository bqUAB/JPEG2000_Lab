#! /usr/bin/octave -qf

pkg load image; % Must be previously installed in Octave

arg_list = argv (); % Read image names from command line input

img1 = arg_list{1}; % img1 = name with extension and full path to image
img2 = arg_list{2}; % img2 = name with extension and full path to image

i1 = imread(img1);
i2 = imread(img2);

psnr_value = psnr(i1,i2);

printf("%f\n", psnr_value);
