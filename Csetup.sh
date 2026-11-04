#!/bin/bash
#
# Debian/Ubuntu post-install setup script.
# Every package manager call is non-interactive (-y / --yes / --noconfirm),
# so nothing stops to ask you to confirm.

set -u

# Keep apt quiet and non-interactive for the whole run.
export DEBIAN_FRONTEND=noninteractive

log() { printf '\n==> %s\n' "$1"; }

# ---------------------------------------------------------------- essentials

log "Installing base tools"
sudo apt-get update -y
sudo apt-get install -y apt-transport-https curl gdebi zenity libnotify-bin

# ---------------------------------------------------------------------- Brave

log "Adding the Brave repository"
# The old 'apt-key' command is removed in Debian 12+ and deprecated in
# Ubuntu 22.04+. Keys now belong in /etc/apt/keyrings, referenced per repo.
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/brave-browser-archive-keyring.gpg > /dev/null

ARCH="$(dpkg --print-architecture)"
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
  | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y brave-browser

# ------------------------------------------------------- remove preinstalled

log "Removing packages most people don't need"
sudo apt-get remove -y ubuntu-web-launchers thunderbird rhythmbox

# ----------------------------------------------------------------- multimedia

log "Installing multimedia apps"
sudo apt-get install -y gimp scribus

# --------------------------------------------------------------------- gaming

log "Installing Steam"
sudo apt-get install -y steam-installer

# Lutris lives in a PPA, which Ubuntu has but plain Debian does not.
log "Installing Lutris"
if sudo apt-get install -y software-properties-common \
   && sudo add-apt-repository -y ppa:lutris-team/lutris \
   && sudo apt-get update -y \
   && sudo apt-get install -y lutris; then
  echo "Lutris installed."
else
  echo "Skipped Lutris - the PPA is Ubuntu-only. Install it manually on Debian."
fi

# -------------------------------------------------------------------- apport

log "Disabling Apport crash reporting"
if [ -f /etc/default/apport ]; then
  sudo sed -i 's/^enabled=1/enabled=0/' /etc/default/apport
  sudo systemctl stop apport.service || true
  sudo systemctl disable apport.service || true
fi

# ---------------------------------------------------------------- dev tools

log "Installing Git and Java"
sudo apt-get install -y git default-jre default-jdk

echo "git:    $(git --version)"
echo "javac:  $(javac -version 2>&1)"
echo "java:   $(java -version 2>&1 | head -n1)"

# ------------------------------------------------------------------- upgrade

log "Finishing with a full upgrade"
sudo apt-get update -y
sudo apt-get upgrade -y

# ------------------------------------------------------------------- message

if command -v zenity >/dev/null 2>&1; then
  zenity --info --text="All Done!" 2>/dev/null || true
fi
if command -v notify-send >/dev/null 2>&1; then
  notify-send 'All Done!' 'Remember to configure your Git identity.' 2>/dev/null || true
fi

echo "All done - remember to configure your Git identity."
