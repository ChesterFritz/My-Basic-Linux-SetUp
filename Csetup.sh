#!/bin/bash
#
# Debian/Ubuntu post-install setup script.
# Every package manager call is non-interactive, so nothing stops to ask you
# to confirm. Repositories are added first so apt only has to refresh once,
# and packages go in as one batch (falling back to one-by-one if the batch
# fails, so a single missing package doesn't block the rest).

set -uo pipefail

export DEBIAN_FRONTEND=noninteractive
APT=(sudo apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

log() { printf '\n==> %s\n' "$1"; }
FAILED=()

# Ask for the sudo password once, then keep it alive for the whole run.
sudo -v || exit 1
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
trap 'kill $! 2>/dev/null' EXIT

# shellcheck source=/dev/null
. /etc/os-release
IS_UBUNTU=0
[[ "${ID:-}" == ubuntu || " ${ID_LIKE:-} " == *" ubuntu "* ]] && IS_UBUNTU=1

install_pkgs() {
  "${APT[@]}" install "$@" && return 0
  echo "Batch install failed - retrying packages one at a time."
  local p
  for p in "$@"; do
    "${APT[@]}" install "$p" || FAILED+=("$p")
  done
}

# ------------------------------------------------------------- repositories

log "Adding repositories"
"${APT[@]}" install curl ca-certificates

# Brave: keyring in /etc/apt/keyrings (apt-key is gone in Debian 12+).
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSLo /etc/apt/keyrings/brave-browser-archive-keyring.gpg \
  https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
  || FAILED+=("brave-keyring")
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
  | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

# Steam needs 32-bit libraries.
sudo dpkg --add-architecture i386

# Lutris lives in a PPA, which only Ubuntu supports.
PKGS_EXTRA=()
if (( IS_UBUNTU )); then
  "${APT[@]}" install software-properties-common
  sudo add-apt-repository -y -n ppa:lutris-team/lutris && PKGS_EXTRA+=(lutris)
else
  echo "Skipping Lutris - the PPA is Ubuntu-only. Install it manually on Debian."
fi

# --------------------------------------------------------- update + upgrade

log "Refreshing package lists and upgrading"
"${APT[@]}" update
"${APT[@]}" full-upgrade

# ------------------------------------------------------- remove preinstalled

log "Removing packages most people don't need"
# Only pass packages that are actually installed - apt aborts the whole
# removal if any name is unknown (e.g. ubuntu-web-launchers on Debian).
REMOVE=()
for p in ubuntu-web-launchers thunderbird rhythmbox; do
  dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'ok installed' && REMOVE+=("$p")
done
if (( ${#REMOVE[@]} )); then
  "${APT[@]}" purge "${REMOVE[@]}"
else
  echo "Nothing to remove."
fi

# ------------------------------------------------------------------ install

log "Installing packages"
install_pkgs \
  gdebi zenity libnotify-bin \
  brave-browser \
  gimp scribus \
  steam-installer \
  git default-jre default-jdk \
  "${PKGS_EXTRA[@]}"

"${APT[@]}" autoremove

# -------------------------------------------------------------------- apport

if [ -f /etc/default/apport ]; then
  log "Disabling Apport crash reporting"
  sudo sed -i 's/^enabled=1/enabled=0/' /etc/default/apport
  sudo systemctl disable --now apport.service 2>/dev/null || true
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
