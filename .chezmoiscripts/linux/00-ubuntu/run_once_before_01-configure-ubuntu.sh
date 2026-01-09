#!/usr/bin/env bash

set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${HOME}/.local/share/soar/bin:${PATH}"

if ! command -v apt &>/dev/null; then
  echo "This script is only for Ubuntu based systems. Exiting..."
  echo "${LINE}"
  exit 1
fi

# Detect distribution and version
if [[ -f /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  DISTRO_NAME="${ID}"
  DISTRO_VERSION="${VERSION_ID}"
  DISTRO_CODENAME="${VERSION_CODENAME:-${UBUNTU_CODENAME-}}"
else
  echo "Cannot detect distribution. /etc/os-release not found."
  exit 1
fi

# Display detected system
if [[ ${DISTRO_NAME} == "ubuntu" ]]; then
  echo "Ubuntu ${DISTRO_VERSION} (${DISTRO_CODENAME}) detected!"
else
  echo "Ubuntu-based system detected: ${DISTRO_NAME} ${DISTRO_VERSION}"
fi

echo "${LINE}"

# Install Nala
if command -v nala &>/dev/null; then
  echo "Nala is already installed. Skipping"
else
  # shellcheck disable=SC2312
  curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
  sudo apt install -t nala nala
fi

echo "${LINE}"

# Setup Nala
sudo nala fetch --auto -y --https-only
sudo nala install --update -y curl wget git ca-certificates libfuse2 gnupg2 flatpak software-properties-common
echo "${LINE}"

# Add Repositories
echo "Setting up repositories for ${DISTRO_NAME} ${DISTRO_VERSION}"

## KeePassXC
sudo add-apt-repository ppa:phoerious/keepassxc -y
echo "${LINE}"

## Waydroid
# shellcheck disable=SC2312
curl https://repo.waydro.id | sudo bash
echo "${LINE}"

## Fastfetch
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
echo "${LINE}"

## GitHub CLI
sudo mkdir -p -m 755 /etc/apt/keyrings
out=$(mktemp)
wget -nv -O"${out}" https://cli.github.com/packages/githubcli-archive-keyring.gpg
# shellcheck disable=SC2312,SC2002
cat "${out}" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
sudo mkdir -p -m 755 /etc/apt/sources.list.d
# shellcheck disable=SC2312
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

echo "${LINE}"

## Waydroid Helper
echo "Setting up Waydroid Helper repository for Ubuntu..."
sudo add-apt-repository ppa:ichigo666/ppa -y
echo -e "Package: python3-pywayland\nPin: origin \"ppa.launchpadcontent.net\"\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/99-ichigo666-ppa.pref

echo "${LINE}"

## OBS Studio
sudo add-apt-repository ppa:obsproject/obs-studio -y
echo "${LINE}"

# Install Soar
# shellcheck disable=SC2312
curl -fsSL "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh
echo "${LINE}"
