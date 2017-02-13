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
#gray_img='./n5_GRAY.pgm'
color_img='./n5_RGB.ppm'
results='results-2c.csv' # results spreadsheet file name

# Calculations
samples=$(echo "scale=2; ($range_max-$range_min)/$step;"|bc); # number of samples
#gray_img_size=$(stat -c%s "$gray_img")
color_img_size=$(stat -c%s "$color_img")

# Spreadsheet initial values, titles, organization, etc.
echo ' ,Gray, ,Color' > $results

echo ' , , ,Cycc=no, ,Cycc=yes' >> $results

echo 'Rate,Real Rate,PSNR,Real Rate,PSNR,Real Rate,PSNR' >> $results

# Swipe through the experimental range
for i in `seq 1 $samples`;
do
  rate=$(echo "scale=2; $i*$step+$range_min;"|bc);
  
  # ----- Cycc=no ------ #
  # JPEG2000 compressed files
  out_j2k_n="./img/img_cycc_n-$i.jp2"
  
  # Decompressed files
  dec_j2k_n="./img/img_cycc_n-$i.ppm"
  
  # Compression
  kdu_compress -i $color_img -o $out_j2k_n -rate $rate Cycc=no

  # Decompression
  kdu_expand -i $out_j2k_n -o $dec_j2k_n
  
  # Calculate the real rate with the filesize
  # filesize*24/resolution 
  # (*24 because we want in bits not bytes and we have 3 components RGB)
  n_filesize=$(stat -c%s "$out_j2k_n")
  n_real_rate=$(echo "scale=8; $n_filesize*24/$color_img_size;"|bc);

  # Comparison
  psnr_n=$(Gcomp -i1 $color_img -i2 $out_j2k_n -m 7 -f 1)
  
  # Delete the images (cleaning)
  rm $out_j2k_n
  rm $dec_j2k_n
  # ------------------ #
  
  # ----- Cycc=yes ------- #
  # JPEG2000 compressed files
  out_j2k_y="./img/img_cycc_y-$i.jp2"
  
  # Decompressed files
  dec_j2k_y="./img/img_cycc_y-$i.ppm"
  
  # Compression
  kdu_compress -i $color_img -o $out_j2k_y -rate $rate Cycc=yes

  # Decompression
  kdu_expand -i $out_j2k_y -o $dec_j2k_y
  
  # Calculate the real rate with the filesize
  # filesize*24/resolution 
  # (*24 because we want in bits not bytes and we have 3 components RGB)
  y_filesize=$(stat -c%s "$out_j2k_y")
  y_real_rate=$(echo "scale=8; $y_filesize*24/$color_img_size;"|bc);

  # Comparison
  psnr_y=$(Gcomp -i1 $color_img -i2 $out_j2k_y -m 7 -f 1)
  
  # Delete the images (cleaning)
  rm $out_j2k_y
  rm $dec_j2k_y
  # ------------------ #

  # Saving the values in the spreadsheet
  echo $rate', , ,'$n_real_rate','$psnr_n','$y_real_rate','$psnr_y',' \
    >> $results

done

echo "*************************"
echo "* Done! Script complete *"
echo "*************************"
