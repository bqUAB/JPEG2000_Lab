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
step="1"
range_min=0
range_max=5
gray_img='./n5_GRAY.pgm'
results='results-3a.csv' # results spreadsheet file name

# Calculations
# number of samples
samples=$(echo "scale=2; ($range_max-$range_min)/$step;"|bc);
gray_img_size=$(stat -c%s "$gray_img")

# Spreadsheet initial values, titles, organization, etc.
echo ' ,LRCP, ,RLCP, ,RPCL, ,PCRL, ,CPRL' > $results

echo 'Rate,Real Rate,PSNR,Real Rate,PSNR,Real Rate,PSNR,'\
  'Real Rate,PSNR,Real Rate,PSNR' >> $results

# Swipe through the experimental range
for i in `seq 1 $samples`;
do
  rate=$(echo "scale=2; $i*$step+$range_min;"|bc);
  
  # ----- LRCP ------ #
  # JPEG2000 compressed files
  out_lrcp="./img/img_lrcp-$i.jp2"
  
  # Decompressed files
  dec_lrcp="./img/img_lrcp-$i.pgm"
  
  # Compression
  kdu_compress -i $gray_img -o $out_lrcp -rate $rate Corder=LRCP

  # Decompression
  kdu_expand -i $out_lrcp -o $dec_lrcp
  
  # Calculate the real rate with the filesize
  # filesize*8/resolution 
  # (*8 because we want in bits not bytes)
  lrcp_filesize=$(stat -c%s "$out_lrcp")
  lrcp_real_rate=$(echo "scale=8; $lrcp_filesize*8/$gray_img_size;"|bc);

  # Comparison
  psnr_lrcp=$(Gcomp -i1 $gray_img -i2 $dec_lrcp -m 7 -f 1)
  
  # Delete the images (cleaning)
  rm $out_lrcp
  rm $dec_lrcp
  # ------------------ #
  
  # ----- RLCP ------ #
  # JPEG2000 compressed files
  out_rlcp="./img/img_rlcp-$i.jp2"
  
  # Decompressed files
  dec_rlcp="./img/img_rlcp-$i.pgm"
  
  # Compression
  kdu_compress -i $gray_img -o $out_rlcp -rate $rate Corder=RLCP

  # Decompression
  kdu_expand -i $out_rlcp -o $dec_rlcp
  
  # Calculate the real rate with the filesize
  # filesize*8/resolution 
  # (*8 because we want in bits not bytes)
  rlcp_filesize=$(stat -c%s "$out_rlcp")
  rlcp_real_rate=$(echo "scale=8; $rlcp_filesize*8/$gray_img_size;"|bc);

  # Comparison
  psnr_rlcp=$(Gcomp -i1 $gray_img -i2 $dec_rlcp -m 7 -f 1)
  
  # Delete the images (cleaning)
  rm $out_rlcp
  rm $dec_rlcp
  # ------------------ #

  # Saving the values in the spreadsheet
  echo $rate','$lrcp_real_rate','$psnr_lrcp','\
    $rlcp_real_rate','$psnr_rlcp','\
    >> $results

done

echo "*************************"
echo "* Done! Script complete *"
echo "*************************"
