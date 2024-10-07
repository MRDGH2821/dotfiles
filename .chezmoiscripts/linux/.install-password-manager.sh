#!/usr/bin/env bash

if type -P keepassxc &>/dev/null; then
  echo "KeepassXC is already installed. Skipping"
  exit 0
fi

if type -P apt &>/dev/null; then
  echo "Installing KeepassXC on Ubuntu/Debian..."
  sudo add-apt-repository ppa:phoerious/keepassxc --yes
  sudo apt update
  sudo apt install -y keepassxc
# Fedora-based
elif type -P dnf &>/dev/null; then
  echo "Installing KeepassXC on Fedora..."
  sudo dnf install -y keepassxc
# Arch Linux-based
elif type -P pacman &>/dev/null; then
  echo "Installing KeepassXC on Arch Linux..."
  sudo pacman -S --noconfirm --needed keepassxc
else
  echo "Unsupported Linux distribution"
  exit 1
fi
