#!/bin/bash
# ---------- Kakadu Script ----------
# This script is used to repeat the kakadu compress command with
# different rates. At the moment the script covers the rates between
# 0.05 to 2. It also uses three different parameters resulting in
# 120 images and 120 text files.
#
# Instructions:
# 1. Create a new directory for binary executables (this is for ubuntu).
#   $ mkdir ~/bin
#
# 2. copy this file into the bin directory
#
# 3. Change the permissions of the binary file to allow execution.
#   $ chmod 755 ~/bin/kakadu_script-1
#
# 3. Logout from the system
#   $ logout
#
# 4. Create the following directory tree
#   lab1            (main directory)
#	|   n5_RGB.ppm  (main image to compress)
#   |---img         (subdirectory for resulting images)
#   |---logs        (subdirectory for resulting logs)
#
# 5. Navigate to the lab1 directory
#	$ cd /path_to_directory/lab1	(depends on the user)
#
# 6. Execute the binary and enjoy
#	$ kakadu_script-1
#
# TO DO: ask the user the value in which to perform the steps.
#
#	---------- License ---------- 
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Define the parameters
step="0.1"
range_min=0
range_max=5
main_img='./n5_GRAY.pgm'
results='results-2b.csv' # results spreadsheet file name

# Calculations
samples=$(echo "scale=2; ($range_max-$range_min)/$step;"|bc); # number of samples
main_img_size=$(stat -c%s "$main_img")

# Spreadsheet initial values, titles, organization, etc.
echo ' ,Creversible=no, , , , , ,Creversible=yes' > $results

echo ' ,Clevels=1, ,Clevels=3, ,Clevels=5,'\
  ' ,Clevels=1, ,Clevels=3, ,Clevels=5' >> $results

echo 'Rate,Real Rate,PSNR,Real Rate,PSNR,Real Rate,PSNR,'\
  'Real Rate,PSNR,Real Rate,PSNR,Real Rate,PSNR'\
  >> $results

# Swipe through the experimental range
for i in `seq 1 $samples`;
do
  rate=$(echo "scale=2; $i*$step+$range_min;"|bc);
  
  # ----- Lossy ------ #
  ## JPEG2000 compressed files
  #out_j2k_l1=./img/img_lossy_l1-$i.jp2
  #out_j2k_l3=./img/img_lossy_l3-$i.jp2
  #out_j2k_l5=./img/img_lossy_l5-$i.jp2
  
  ## Decompressed files
  #dec_j2k_l1=./img/img_lossy_l1-$i.pgm
  #dec_j2k_l3=./img/img_lossy_l3-$i.pgm
  #dec_j2k_l5=./img/img_lossy_l5-$i.pgm
  
  # Compression
  kdu_compress -i $main_img -o ./img/img_lossy_l1-$i.jp2 \
    -rate $rate Creversible=no Clevels=1
  kdu_compress -i $main_img -o ./img/img_lossy_l3-$i.jp2 \
    -rate $rate Creversible=no Clevels=3
  kdu_compress -i $main_img -o ./img/img_lossy_l5-$i.jp2 \
    -rate $rate Creversible=no Clevels=5

  # Decompression
  kdu_expand -i ./img/img_lossy_l1-$i.jp2 -o ./img/img_lossy_l1-$i.pgm
  kdu_expand -i ./img/img_lossy_l3-$i.jp2 -o ./img/img_lossy_l3-$i.pgm
  kdu_expand -i ./img/img_lossy_l5-$i.jp2 -o ./img/img_lossy_l5-$i.pgm
  
  # Calculate the real rate with the filesize
  # filesize*8/resolution (*8 because we want in bits not bytes)
  lossy_filesize1=$(stat -c%s "./img/img_lossy_l1-$i.jp2")
  lossy_filesize3=$(stat -c%s "./img/img_lossy_l3-$i.jp2")
  lossy_filesize5=$(stat -c%s "./img/img_lossy_l5-$i.jp2")
  
  lossy_real_rate1=$(echo "scale=8; $lossy_filesize1*8/$main_img_size;"|bc);
  lossy_real_rate3=$(echo "scale=8; $lossy_filesize3*8/$main_img_size;"|bc);
  lossy_real_rate5=$(echo "scale=8; $lossy_filesize5*8/$main_img_size;"|bc);

  # Comparison
  psnr_lossy1=$(Gcomp -i1 $main_img -i2 ./img/img_lossy_l1-$i.pgm -m 7 -f 1)
  psnr_lossy3=$(Gcomp -i1 $main_img -i2 ./img/img_lossy_l3-$i.pgm -m 7 -f 1)
  psnr_lossy5=$(Gcomp -i1 $main_img -i2 ./img/img_lossy_l5-$i.pgm -m 7 -f 1)
  # ------------------ #
  
  # ----- PLTL ------- #
  # Compression
  kdu_compress -i $main_img -o ./img/img_pltl_l1-$i.jp2\
    -rate $rate Creversible=yes Clevels=1
  kdu_compress -i $main_img -o ./img/img_pltl_l3-$i.jp2\
    -rate $rate Creversible=yes Clevels=3
  kdu_compress -i $main_img -o ./img/img_pltl_l5-$i.jp2\
    -rate $rate Creversible=yes Clevels=5

  # Decompression
  kdu_expand -i ./img/img_pltl_l1-$i.jp2 -o ./img/img_pltl_l1-$i.pgm
  kdu_expand -i ./img/img_pltl_l3-$i.jp2 -o ./img/img_pltl_l3-$i.pgm
  kdu_expand -i ./img/img_pltl_l5-$i.jp2 -o ./img/img_pltl_l5-$i.pgm
  
  # Calculate the real rate with the filesize
  # filesize*8/resolution (*8 because we want in bits not bytes)
  pltl_filesize1=$(stat -c%s "./img/img_pltl_l1-$i.jp2")
  pltl_filesize3=$(stat -c%s "./img/img_pltl_l3-$i.jp2")
  pltl_filesize5=$(stat -c%s "./img/img_pltl_l5-$i.jp2")
  
  pltl_real_rate1=$(echo "scale=8; $pltl_filesize1*8/$main_img_size;"|bc);
  pltl_real_rate3=$(echo "scale=8; $pltl_filesize3*8/$main_img_size;"|bc);
  pltl_real_rate5=$(echo "scale=8; $pltl_filesize5*8/$main_img_size;"|bc);

  # Comparison
  psnr_pltl_1=$(Gcomp -i1 $main_img -i2 ./img/img_pltl_l1-$i.pgm -m 7 -f 1) 
  psnr_pltl_3=$(Gcomp -i1 $main_img -i2 ./img/img_pltl_l3-$i.pgm -m 7 -f 1) 
  psnr_pltl_5=$(Gcomp -i1 $main_img -i2 ./img/img_pltl_l5-$i.pgm -m 7 -f 1) 
  # ------------------ #

  # Saving the values in the spreadsheet
  echo $rate','\
    $lossy_real_rate1','$psnr_lossy1','\
    $lossy_real_rate3','$psnr_lossy3','\
    $lossy_real_rate5','$psnr_lossy5','\
    $pltl_real_rate1','$psnr_pltl_1','\
    $pltl_real_rate3','$psnr_pltl_3','\
    $pltl_real_rate5','$psnr_pltl_5',' >> $results

  # Delete the images (cleaning)
  rm ./img/img_lossy_l1-$i.jp2
  rm ./img/img_lossy_l3-$i.jp2
  rm ./img/img_lossy_l5-$i.jp2
  rm ./img/img_pltl_l1-$i.jp2
  rm ./img/img_pltl_l3-$i.jp2
  rm ./img/img_pltl_l5-$i.jp2
  
  rm ./img/img_lossy_l1-$i.pgm
  rm ./img/img_lossy_l3-$i.pgm
  rm ./img/img_lossy_l5-$i.pgm
  rm ./img/img_pltl_l1-$i.pgm
  rm ./img/img_pltl_l3-$i.pgm
  rm ./img/img_pltl_l5-$i.pgm
done

echo "*************************"
echo "* Done! Script complete *"
echo "*************************"
