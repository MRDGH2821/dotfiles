#!/usr/bin/env bash

if command -v keepassxc &>/dev/null; then
  echo "KeepassXC is already installed. Skipping"
  exit 0
fi

if command -v apt &>/dev/null; then
  echo "Installing KeepassXC on Ubuntu/Debian..."
  sudo add-apt-repository ppa:phoerious/keepassxc --yes
  sudo apt update
  sudo apt install -y keepassxc
# Fedora-based
elif command -v dnf &>/dev/null; then
  echo "Installing KeepassXC on Fedora..."
  sudo dnf install -y keepassxc
# Arch Linux-based
elif command -v pacman &>/dev/null; then
  echo "Installing KeepassXC on Arch Linux..."
  sudo pacman -S --noconfirm --needed keepassxc
else
  echo "Unsupported Linux distribution"
  exit 1
fi
