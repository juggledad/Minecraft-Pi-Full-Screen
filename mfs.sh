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
# 4 - check for the '/home/pi/mfs.mfs.sh' file, create it if it doesn't exist
# 5 - has /boot/config.txt been copied to the /boot directory, if not copy it
# 6 - change the /boot/config.txt file to adjust the screen resolution
# to allow Minecraft Pi to fill the screen by reducing the screen resolution.
#

echo "Raspberry Pi Mindcraft Full Screen (mfs) setup script"
echo " "

# ====================================
# 1 - report the users IP address
# ====================================
echo "Please make note of your IP address(es) for use with SSH. If you have"
echo "problems, you can SSH into the Pi and rerun the script using the format:"
echo " "
echo "ssh pi@yourIPaddress"
echo " "
echo "or you can power down the Pi, remove the SD card, put it in a card reader" 
echo "attach it to your Mac or PC. Then you can delete the 'config.txt' file,"
echo "rename 'config.boot' to 'config.txt', unmount the card, put it back in the"
echo "Pi and power the Pi on. This wil get you back to your original settings."
echo " "
hostname -I
echo " "
read -p "Did you write your IP address down? (y/N) ? " yn
case $yn in
	[Yy]* )
	;;
	* )
		echo "Please make note of your IP address(es) and re-run this script."
		exit
	;;
esac

# ====================================
# 2 - turning on SSH
# ====================================
#echo "Enabling SSH -----------"
sudo update-rc.d ssh enable
#echo "Enabling SSH completed -----------"

# ====================================
# 3 - check for the '/home/pi/mfs' directory and create it if it doesn't exist
# ====================================
#echo "Check for the mfs directory" 
if [ ! -d /home/pi/mfs ]; 
then
	mkdir mfs
fi

# ====================================
# 4 - check for the '/home/pi/mfs/mfs.sh' file and copy it if it doesn't exist
# ====================================
#echo "Check for the mfs.sh file" 
if [ ! -f /home/pi/mfs/mfs.sh ]; 
then
	curl https://raw.githubusercontent.com/juggledad/Minecraft-Pi-Full-Screen/master/mfs.sh > /home/pi/mfs/mfs.sh 
fi

# ====================================
# 5 - has /boot/config.txt been backed up, if not copy it
# ====================================
#echo "backup /boot/config.txt " 
if [ ! -f /boot/config.boot ];
then
	sudo bash -c "sudo cat /boot/config.txt > /boot/config.boot"
	echo "/boot/config.txt backed up to /boot/config.boot"
else
	read -p "Do you want to restore the original settings? (y/N) ? " yn
	case $yn in
		[Yy]* )
			sudo bash -c "sudo cat /boot/config.boot > /boot/config.txt"
			echo "Reboot to use the original configuration"
			exit
		;;
		* )
		;;
	esac

	read -p "Do you want to use the stored Minecraft Full Screen settings? (y/N) ? " yn
	case $yn in
		[Yy]* )
			sudo bash -c "sudo cat /boot/config.mfs > /boot/config.txt"
			echo "Reboot to use the full screen configuration"
			exit
		;;
		* )
		;;
	esac
fi
# ====================================
# 6 - change the /boot/config.txt file to adjust the screen resolution
# to allow Minecraft Pi to fill the screen by reducing the screen resolution.
# ====================================
#echo '6 - Updating config.txt'
echo "Enter the hdmi_group (1 or 2) and the hdmi_mode" 
echo "  for hdmi_group 1, the hdmi_mode can be from 1 to 59"
echo "  for hdmi_group 2, the hdmi_mode can be from 1 to 86" 
echo "(for details see: https://www.raspberrypi.org/documentation/configuration/config-txt/video.md)" 
echo "To run  Minecraft full screen on a TV with HDMI in or on a computer monitor"
echo "try hdmi_group 2 and hdmi_mode 14"
echo ""
while true; do
	read -p "Use the defaults: group=2, mode=14 (y/n)? " dg
	case $dg in
		[Yy]* )
			hg=2
			hm=14
			break
		;;
		* ) 
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
				break
			fi
			if [ $hg = 2 ]; 
			then
				read -p "Enter hdmi_mode (1 thru 86) ? " hm
				break
			fi
		done
		break
		;;
	esac
done

cat /boot/config.boot > /home/pi/mfs/config.mfs
cat <<EOT > /tmp/tmpworkfile

# settings to reduce the screen resolution to run Minecraft Pi full screen
hdmi_safe=0
hdmi_group=$hg
hdmi_mode=$hm
EOT
cat /tmp/tmpworkfile >> /home/pi/mfs/config.mfs

sudo rm /tmp/tmpworkfile
sudo bash -c "sudo cat /home/pi/mfs/config.mfs > /boot/config.txt"

echo " "
echo "All done - reboot for changes to take effect"
echo "You can rerun this script from the mfs directory using:"
echo "     sh /home/pi/mfs/mfs.sh"
echo "to swap 'full screen' <=> 'orginal settings' or recreate the full screen settings"
