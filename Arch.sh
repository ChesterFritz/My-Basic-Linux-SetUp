#!/bin/bash
#
# Arch Linux post-install setup script.
# Every pacman call uses --noconfirm, so nothing stops to ask you to confirm.

set -u

log() { printf '\n==> %s\n' "$1"; }

log "Updating the system"
sudo pacman -Syyu --noconfirm

log "Installing base tools"
sudo pacman -S --noconfirm --needed curl git zenity

log "Installing Brave"
sudo pacman -S --noconfirm --needed brave-browser

log "Installing multimedia apps"
sudo pacman -S --noconfirm --needed gimp

log "Installing Java"
# 'default-jre' and 'default-jdk' are Debian package names.
# On Arch they are 'jre-openjdk' and 'jdk-openjdk'.
sudo pacman -S --noconfirm --needed jre-openjdk jdk-openjdk

echo "javac:  $(javac -version 2>&1)"
echo "java:   $(java -version 2>&1 | head -n1)"

# ------------------------------------------------------------------- message

if command -v zenity >/dev/null 2>&1; then
  zenity --info --text="All Done!" 2>/dev/null || true
fi
if command -v notify-send >/dev/null 2>&1; then
  notify-send 'All Done!' 'Remember to install Git and configure your identity.' 2>/dev/null || true
fi

echo "All done - remember to install Git and configure your identity."
