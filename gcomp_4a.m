ref = imread('n5_RGB.ppm');
quality = ones(1,10);
psnr_jpg = ones(1,10);
psnr_jp2 = ones(1,10);
for x = 1:10
    quality(x) = x+90;
    
    % JPEG
    temp = imread(sprintf('n5_RGB-%d.ppm',quality(x)));
    psnr_jpg(x) = psnr(temp, ref);
    
    % JPEG2000
    temp = imread(sprintf('n5_RGB-jp2-%d.ppm',quality(x)));
    psnr_jp2(x) = psnr(temp, ref);
end

quality = quality';
psnr_jpg = psnr_jpg';
psnr_jp2 = psnr_jp2';
