#!/usr/bin/env bash
set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${HOME}/.local/share/soar/bin:${PATH}"

if ! command -v pacman &>/dev/null; then
  echo "This script is only for Arch based systems. Exiting..."
  echo "${LINE}"
  exit 1
fi

echo "Arch based system found!"
# Setup Chaotic AUR repo
if ! grep -q '\[chaotic-aur\]' /etc/pacman.conf; then
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

  # shellcheck disable=SC2312
  sudo echo '[chaotic-aur]' | sudo tee -a /etc/pacman.conf
  # shellcheck disable=SC2312
  sudo echo 'Include = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf
  echo "Chaotic AUR Repo added!"

else
  echo "Chaotic AUR Repo already present."
fi

echo "${LINE}"

# Install AUR helpers & Flatpak
sudo pacman -S --noconfirm yay paru flatpak --needed

# Install Soar
curl -fsSL "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh

echo "${LINE}"
