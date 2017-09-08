#!/bin/bash
#
# Copyright 2017 Paul M. Woodard
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is designed to:
# 1 - report the users IP address
# 2 - turning on SSH
# 3 - check for the '/home/pi/mfs' directory and create it if it doesn't exist
# 4 - has /boot/config.txt been copied to the mfs directory, if not copy it
# 5 - change the /boot/config.txt file to adjust the screen resolution
# to allow Minecraft Pi to fill the screen by reducing the screen resolution.
#

echo  "Raspberry Pi Mindcraft Full Screen (mfs) setup script\n"

# ====================================
# 1 - report the users IP address
# ====================================
echo "Please make note of your IP address(es) for use with SSH."
echo "If you have problems, you can SSH into the Pi and rerun the script"
echo "using the the format: ssh pi@yourIPaddress"
hostname -I
read -p "Did you write your IP address down? (y/N) ? " yn
case $yn in
  [Yy]* )
  ;;
  * )
    echo "\nPlease make note of your IP address(es) and re-run this script.\r\n"
    exit
  ;;
esac

# ====================================
# 2 - turning on SSH
# ====================================
#echo "Enabling SSH -----------\n"
sudo update-rc.d ssh enable
#echo "Enabling SSH completed -----------\n"

# ====================================
# 3 - check for the '/home/pi/mfs' directory and create it if it doesn't exist
# ====================================
#echo "Check for the mfs directory" 
if [ ! -d /home/pi/mfs ]; 
then
        echo "the directory does not exist - please reinstall"
        exit
fi

# ====================================
# 4 - has /boot/config.txt been copied to the mfs directory, if not copy it
# ====================================
#echo "backup /boot/config.txt " 
if [ ! -f /home/pi/mfs/config.boot ];
then
	cp /boot/config.txt /home/pi/mfs/config.boot
	echo "config.txt backed up to /home/pi/mfs/config.boot"
fi

read -p "Do you want to restore the original settings? (y/N) ? " yn
case $yn in
  [Yy]* )
    sudo bash -c "sudo cat /home/pi/mfs/config.boot > /boot/config.txt"
    echo "Reboot to use the original configuration"
    exit
  ;;
  * )
  ;;
esac

read -p "Do you want to use the stored Minecraft Full Screen settings? (y/N) ? " yn
case $yn in
  [Yy]* )
    sudo bash -c "sudo cat /home/pi/mfs/config.mfs > /boot/config.txt"
    echo "Reboot to use the full screen configuration"
    exit
  ;;
  * )
  ;;
esac

# ====================================
# 5 - change the /boot/config.txt file to adjust the screen resolution
# to allow Minecraft Pi to fill the screen by reducing the screen resolution.
# ====================================
#echo '5 - Updating config.txt'
echo "Enter the hdmi_group (1 or 2) and the hdmi_mode" 
echo "  for hdmi_group 1, the hdmi_mode can be from 1 to 59"
echo "  for hdmi_group 2, the hdmi_mode can be from 1 to 86" 
echo "(for details see: https://www.raspberrypi.org/documentation/configuration/config-txt/video.md)\n" 
echo "To run  Minecraft full screen on a TV with HDMI in or on a computer monitor"
echo "try hdmi_group 2 and hdmi_mode 14"
 
while true; do
	read -p "Enter hdmi_group (1 or 2) ? " hg
	case $hg in
      [12]* )
      break;;
      * )
      ;;
    esac
done

while true; do
        if [ $hg = 1 ];
        then
          read -p "Enter hdmi_mode (1 thru 59) ? " hm
        fi
        if [ $hg = 2 ]; 
        then
          read -p "Enter hdmi_mode (1 thru 86) ? " hm
        fi

        case $hg in
      [12]* )
      break;;
      * )
      ;; 
    esac
done

cd /home/pi/mfs
cat /home/pi/mfs/config.boot > /home/pi/mfs/config.mfs
cat <<EOT > /tmp/tmpworkfile

# settings to reduce the screen resolution to run Minecraft Pi full screen
hdmi_safe=0
hdmi-group=$hg
hdmi-mode=$hm
EOT
cat /tmp/tmpworkfile >> /home/pi/mfs/config.mfs

sudo rm /tmp/tmpworkfile
sudo bash -c "sudo cat /home/pi/mfs/config.mfs > /boot/config.txt"

echo "--------------------\nAll done - reboot for changes to take effect"
