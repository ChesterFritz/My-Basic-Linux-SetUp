#!/bin/dash


sudo pacman -Syyu

echo installing brave

sudo pacman -S brave-browser

## Multimedia
sudo pacman -S gimp

# Install Java 
sudo pacman -S default-jre
sudo pacman -S default-jdk
javac -version
java -version
echo Java is Installed 



# Message:
zenity --info --text="All Done!"
notify-send 'All Done!' 'remember to install git besktop'
