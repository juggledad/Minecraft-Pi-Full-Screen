# Minecraft-Pi-Full-Screen
Script to allow you to set your monitor so Minecraft runs full screen

Minecraft can not be expanded to run on your monitor full screen because the Pi just doesn't have the horsepower to run it. However, you can reduce the resolution of your screen so the Minecraft window will fill the entire screen.

This script allows you to adjust your monitor or TV with an hdmi input so Minecraft will fill the screen when using it. Once you have created a setup that works, you can run the screipt to swap back and forth between the two config files.

The settings that seem to work best are:
- hdmi_safe=0
- hdmi_group=2
- hdmi_mode=14

# Directions
copy the code to your Pi and type:
# sh mfs/mfs-setup.sh
and follow the directions.
