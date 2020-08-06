#!/bin/dash

# Ubuntu My (GNOME) setup script.

dpkg -l | grep -qw gdebi || sudo apt-get install -yyq gdebi

# Check for Update

sudo apt update

# Purge Firefox (if you wan), install Brave:

#sudo apt purge firefox -yy
#sudo apt purge firefox-locale-en -yy
#if [ -d "/home/$USER/.mozilla" ]; then
#    rm -rf /home/$USER/.mozilla
#fi
#if [ -d "/home/$USER/.cache/mozilla" ]; then
#    rm -rf /home/$USER/.cache/mozilla
#fi

sudo apt install apt-transport-https curl

curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser

## Remove junk
sudo apt-get remove ubuntu-web-launchers thunderbird rhythmbox -y

## Multimedia
sudo apt-get install -y gimp scribus

## Games
sudo apt-get install -y steam-installer
sudo apt install steam-installer

## Disable Apport
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Update it ALL:
sudo apt update && sudo apt upgrade -y

# Install Git on Linux:
sudo apt-get update
sudo apt-get install git
git --version


# Message:
zenity --info --text="All Done!"
notify-send 'All Done!' 'remember to configure your Git'
