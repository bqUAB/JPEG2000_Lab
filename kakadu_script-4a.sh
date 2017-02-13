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

# -----------------------------
# Initial declaration of values

# Raw grayscales images name and name with complete path
gray_img_name='n5_GRAY'
gray_img_full='./test_img/n5_GRAY.pgm'

# Raw RGB images name and name with complete path
rgb_img_name='n5_RGB'
rgb_img_full='./test_img/n5_RGB.ppm'

# Raw images size
gray_img_size=$(stat -c%s "$gray_img_full")
rgb_img_size=$(stat -c%s "$rgb_img_full")

# Define the parameters
step="1"
range_min=19
range_max=30

# ------------------------------------------------------
# Results spreadsheet (comma separated values) file name
results='results-4a.csv' 

# Spreadsheet initial values, titles, organization, etc.
echo ' ,Grayscale, , , ,RGB' > $results
echo ' ,JPEG, , JPEG2000, ,JPEG, , JPEG2000' >> $results
echo 'Quality,PSNR,Size,PSNR,Size,Relation,'\
  'PSNR,Size,PSNR,Size,Relation'\
  >> $results

# ----------------------------------------------
# Turn raw images to jpeg of different qualities

# Calculations

# number of resulting images
num_img=$(echo "scale=2; ($range_max-$range_min)/$step;"|bc);

# Swipe through the experimental range
for i in `seq 1 $num_img`;
do
  # ----------------------------------
  # Starting values for each iteration
  
  quality=$(echo "scale=2; $i*$step+$range_min;"|bc);
  
  # Grayscale file names with path
  out_jpg="./img/$gray_img_name-$quality.jpg"
  out_jp2="./img/$gray_img_name-$quality.jp2"
  
  # Grayscale decompressed file names with path
  dec_jpg="./img/$gray_img_name-$quality.pgm"
  dec_jp2="./img/$gray_img_name-jp2-$quality.pgm"
  
  # RGB (color) file names with path
  out_rgb_jpg="./img/$rgb_img_name-$quality.jpg"
  out_rgb_jp2="./img/$rgb_img_name-$quality.jp2"
  
  # RGB decompressed file names with path
  dec_rgb_jpg="./img/$rgb_img_name-$quality.ppm"
  dec_rgb_jp2="./img/$rgb_img_name-jp2-$quality.ppm"
  
  # ----------------------------------
  # JPEG compression and decompression
  
  # Convert the raw images to the specified jpeg quality
  convert -quality $quality% $gray_img_full $out_jpg
  convert -quality $quality% $rgb_img_full $out_rgb_jpg
    
  # Decompressed jpeg files
  convert -quality 100% $out_jpg $dec_jpg
  convert -quality 100% $out_rgb_jpg $dec_rgb_jpg
  
  # Print information
  echo "************************"
  echo "* JPEG processing done *"
  echo "************************"  
  echo "$out_jpg created and decompressed."
  echo "$out_rgb created and decompressed."
  #sleep 2
  
  # --------------------------------------
  # JPEG2000 compression and decompression
  
  ## Compress the decoded JPEG files with JPEG2000
  kdu_compress -i $dec_jpg -o $out_jp2 Creversible=yes
  kdu_compress -i $dec_rgb_jpg -o $out_rgb_jp2 Creversible=yes
  
  # Decompression
  kdu_expand -i $out_jp2 -o $dec_jp2
  kdu_expand -i $out_rgb_jp2 -o $dec_rgb_jp2
  
  # Print information
  echo "****************************"
  echo "* JPEG2000 processing done *"
  echo "****************************"  
  echo "$out_jp2 created and decompressed."
  echo "$out_rgb_jp2 created and decompressed."
  #sleep 2
  
  # ---------------------------------
  # Comparison of JPEG and Raw images
  
  # PSNR calculation for the decoded the JPEG
  psnr_gray_jpg=$(Gcomp -i1 $gray_img_full -i2 $dec_jpg -m 7 -f 1)
  #psnr_rgb_jpg=$(Gcomp -i1 $rgb_img_full -i2 $dec_rgb_jpg -m 7 -f 1)
  
  # JPEG images size
  gray_jpg_img_size=$(stat -c%s "$out_jpg")
  rgb_jpg_img_size=$(stat -c%s "$out_rgb_jpg")
  
  # -------------------------------------
  # Comparison of JPEG2000 and Raw images
  # PSNR calculation for the decoded the JPEG2000
  psnr_gray_jp2=$(Gcomp -i1 $gray_img_full -i2 $dec_jp2 -m 7 -f 1)
  #psnr_rgb_jp2=$(Gcomp -i1 $rgb_img_full -i2 $dec_rgb_jp2 -m 7 -f 1)
  
  # JPEG2000 images size
  gray_jp2_img_size=$(stat -c%s "$out_jp2")
  rgb_jp2_img_size=$(stat -c%s "$out_rgb_jp2")
  
  # ------------------------------------------
  # Relation between JPEG and JPEG2000 file sizes
  
  relation_gray=$(echo "scale=2; ($gray_jpg_img_size-$gray_jp2_img_size)/$gray_jpg_img_size;"|bc);
  relation_rgb=$(echo "scale=2; ($rgb_jpg_img_size-$rgb_jp2_img_size)/$rgb_jpg_img_size;"|bc);
  
  # Print information
  echo "*******************************"
  echo "* Comparisson processing done *"
  echo "*******************************"  
  echo "$relation_gray relation for grayscale."
  echo "$relation_rgb relation for RGB."
  #sleep 2
  
  ## Calculate the real rate with the filesize
  ## filesize*8/resolution 
  ## (*8 because we want in bits not bytes)
  #lrcp_filesize=$(stat -c%s "$out_lrcp")
  #lrcp_real_rate=$(echo "scale=8; $lrcp_filesize*8/$gray_img_size;"|bc);

  # -------------------------------------
  # Writing the values to the spreadsheet
  echo $quality','$psnr_gray_jpg','$gray_jpg_img_size','\
    $psnr_gray_jp2','$gray_jp2_img_size','$relation_gray','\
    $psnr_rgb_jpg','$rgb_jpg_img_size','\
    $psnr_rgb_jp2','$rgb_jp2_img_size','$relation_rgb\
    >> $results
    
  # Print information
  echo "******************************************"
  echo "* Writing values to the spreadsheet done *"
  echo "******************************************"  
  #sleep 2
  
  # ----------------------------  
  # Delete the images (cleaning)
  rm $out_jpg
  rm $out_jp2
  
  rm $out_rgb_jpg
  rm $out_rgb_jp2
  
  rm $dec_jpg
  rm $dec_jp2
  
  rm $dec_rgb_jpg
  rm $dec_rgb_jp2
  
  # Print information
  echo "********************************"
  echo "* Clean and delete images done *"
  echo "********************************"  
  #sleep 2
done

echo "*************************"
echo "* Done! Script complete *"
echo "*************************"
