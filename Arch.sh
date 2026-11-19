#!/bin/bash
#
# Arch Linux post-install setup script.
# The upgrade and all official-repo packages go in as a single pacman
# transaction with --noconfirm, so nothing stops to ask you to confirm.

set -uo pipefail

log() { printf '\n==> %s\n' "$1"; }
FAILED=()

# Ask for the sudo password once, then keep it alive for the whole run.
sudo -v || exit 1
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
trap 'kill $! 2>/dev/null' EXIT

PKGS=(
  curl git zenity libnotify   # base tools
  gimp                        # multimedia
  jdk-openjdk                 # Java (pulls in jre-openjdk)
)

log "Upgrading the system and installing packages"
# -Syu (not -Syy): a forced refresh of every database is only needed after
# changing mirrors, and installing in the same transaction as the upgrade
# avoids partial upgrades.
sudo pacman -Syu --noconfirm --needed "${PKGS[@]}" || FAILED+=("pacman")

# Brave isn't in the official repos - it's 'brave-bin' in the AUR.
log "Installing Brave"
if command -v paru >/dev/null; then
  paru -S --noconfirm --needed brave-bin || FAILED+=("brave-bin")
elif command -v yay >/dev/null; then
  yay -S --noconfirm --needed brave-bin || FAILED+=("brave-bin")
elif command -v flatpak >/dev/null; then
  flatpak install -y --noninteractive flathub com.brave.Browser || FAILED+=("brave (flatpak)")
else
  echo "Skipped Brave - install an AUR helper (paru/yay) or flatpak first."
  FAILED+=("brave (no AUR helper)")
fi

# ------------------------------------------------------------------ summary

log "Versions"
echo "git:    $(git --version 2>&1)"
echo "javac:  $(javac -version 2>&1)"
echo "java:   $(java -version 2>&1 | head -n1)"

if (( ${#FAILED[@]} )); then
  MSG="Finished, but these failed: ${FAILED[*]}"
else
  MSG="All Done! Remember to configure your Git identity."
fi

command -v notify-send >/dev/null && notify-send 'Setup finished' "$MSG" 2>/dev/null
command -v zenity      >/dev/null && zenity --info --text="$MSG" 2>/dev/null
echo
echo "$MSG"
(( ${#FAILED[@]} == 0 ))
