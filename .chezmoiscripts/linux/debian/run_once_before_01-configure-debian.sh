#!/usr/bin/env bash

set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v apt &>/dev/null; then
  echo "This script is only for Debian based systems. Exiting..."
  echo "${LINE}"
  exit 1
fi

echo "Debian based system found!"
# Install Nala
if command -v nala &>/dev/null; then
  echo "Nala is already installed. Skipping"

else
  curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
  sudo apt install -t nala nala
fi

echo "${LINE}"

# Setup Nala
sudo nala fetch --auto -y --https-only --non-free
sudo nala install --update -y curl wget git ca-certificates libfuse2 gnupg2 flatpak
echo "${LINE}"

# Add Repositories
echo "Setting up repositories"

## KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc -y
echo "${LINE}"

## Waydroid
curl https://repo.waydro.id | sudo bash
echo "${LINE}"

## Fastfetch
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
echo "${LINE}"

## GitHub CLI
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

echo "${LINE}"
