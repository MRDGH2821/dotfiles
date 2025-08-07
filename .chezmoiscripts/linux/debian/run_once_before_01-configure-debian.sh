#!/usr/bin/env bash

set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v apt &>/dev/null; then
  echo "This script is only for Debian based systems. Exiting..."
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
if [[ ${DISTRO_NAME} == "debian" ]]; then
  echo "Debian ${DISTRO_VERSION} (${DISTRO_CODENAME}) detected!"
  if [[ ${DISTRO_VERSION} == "12" ]]; then
    echo "Running on Debian 12 (Bookworm)"
  else
    echo "Warning: This script is optimized for Debian 12, but detected version ${DISTRO_VERSION}"
  fi
elif [[ ${DISTRO_NAME} == "ubuntu" ]]; then
  echo "Ubuntu ${DISTRO_VERSION} (${DISTRO_CODENAME}) detected!"
else
  echo "Debian-based system detected: ${DISTRO_NAME} ${DISTRO_VERSION}"
fi
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
sudo nala fetch --auto -y --https-only --non-free
sudo nala install --update -y curl wget git ca-certificates libfuse2 gnupg2 flatpak
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
# shellcheck disable=SC2312
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
# shellcheck disable=SC2312
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

echo "${LINE}"

## Waydroid Helper
if [[ ${DISTRO_NAME} == "debian" ]] && [[ ${DISTRO_VERSION} == "12" ]]; then
  echo "Setting up Waydroid Helper repository for Debian 12..."
  echo 'deb http://download.opensuse.org/repositories/home:/CuteNeko:/waydroid-helper/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:CuteNeko:waydroid-helper.list
  # shellcheck disable=SC2312
  curl -fsSL https://download.opensuse.org/repositories/home:CuteNeko:waydroid-helper/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_CuteNeko_waydroid-helper.gpg >/dev/null
  echo -e "Package: python3-pywayland\nPin: origin \"download.opensuse.org\"\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/99-pywayland.pref
elif [[ ${DISTRO_NAME} == "ubuntu" ]]; then
  echo "Setting up Waydroid Helper repository for Ubuntu..."
  sudo add-apt-repository ppa:ichigo666/ppa -y
  echo -e "Package: python3-pywayland\nPin: origin \"ppa.launchpadcontent.net\"\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/99-ichigo666-ppa.pref
else
  echo "Warning: Waydroid Helper repository not available for ${DISTRO_NAME} ${DISTRO_VERSION}"
fi

echo "${LINE}"
