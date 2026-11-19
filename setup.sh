#!/bin/bash
#
# Launcher: pick your distro from a menu, confirm, and run its setup script.
# Uses whiptail or dialog when available, otherwise a plain text menu.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TITLE="My Basic Linux SetUp"

# Pre-select the distro we're running on.
DETECTED=""
if [ -r /etc/os-release ]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*)                   DETECTED=arch ;;
    *" debian "*|*" ubuntu "*)    DETECTED=debian ;;
  esac
fi

describe() {
  case "$1" in
    arch)   echo "Arch.sh will:
  - upgrade the system (pacman -Syu)
  - install curl, git, zenity, libnotify, GIMP, OpenJDK
  - install Brave (AUR via paru/yay, or Flatpak)" ;;
    debian) echo "Csetup.sh will:
  - add the Brave repo (and the Lutris PPA on Ubuntu)
  - upgrade the system (apt full-upgrade)
  - remove thunderbird, rhythmbox, ubuntu-web-launchers
  - install Brave, GIMP, Scribus, Steam, Git, Java (+ Lutris)
  - disable Apport" ;;
  esac
}

TUI=""
if [ -t 0 ] && [ -t 1 ]; then
  command -v whiptail >/dev/null && TUI=whiptail
  [ -z "$TUI" ] && command -v dialog >/dev/null && TUI=dialog
fi

if [ -n "$TUI" ]; then
  on()  { [ "$DETECTED" = "$1" ] && echo ON || echo OFF; }
  CHOICE=$("$TUI" --title "$TITLE" --radiolist \
    "Select your distro${DETECTED:+ (detected: $DETECTED)}:" 12 60 2 \
    debian "Debian / Ubuntu based" "$(on debian)" \
    arch   "Arch based"            "$(on arch)" \
    3>&1 1>&2 2>&3) || { clear; echo "Cancelled."; exit 1; }
  [ -z "$CHOICE" ] && { clear; echo "Nothing selected."; exit 1; }
  "$TUI" --title "$TITLE" --yesno "$(describe "$CHOICE")

Install now?" 16 64 || { clear; echo "Cancelled."; exit 1; }
  clear
else
  echo "== $TITLE =="
  [ -n "$DETECTED" ] && echo "Detected: $DETECTED"
  PS3="Select your distro: "
  select opt in "Debian / Ubuntu based" "Arch based" "Quit"; do
    case "$REPLY" in
      1) CHOICE=debian; break ;;
      2) CHOICE=arch;   break ;;
      3) echo "Cancelled."; exit 1 ;;
    esac
  done
  echo
  describe "$CHOICE"
  read -rp $'\nInstall now? [y/N] ' ans
  [[ "$ans" =~ ^[Yy] ]] || { echo "Cancelled."; exit 1; }
fi

if [ -n "$DETECTED" ] && [ "$CHOICE" != "$DETECTED" ]; then
  echo "Warning: you picked $CHOICE but this system looks like $DETECTED."
  read -rp "Continue anyway? [y/N] " ans
  [[ "$ans" =~ ^[Yy] ]] || { echo "Cancelled."; exit 1; }
fi

case "$CHOICE" in
  arch)   exec bash "$DIR/Arch.sh" ;;
  debian) exec bash "$DIR/Csetup.sh" ;;
esac
