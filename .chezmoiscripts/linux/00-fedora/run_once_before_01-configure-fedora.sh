#!/usr/bin/env bash
set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${HOME}/.local/share/soar/bin:${PATH}"

if ! command -v dnf &>/dev/null; then
  echo "dnf not found. This script is only for Fedora based systems. Exiting..."
  echo "${LINE}"
  exit 1
fi

echo "Fedora based system found!"
# Install dnf5 for faster downloads, flatpak & gh cli
sudo dnf install dnf5 flatpak gh -y
echo "${LINE}"

# modify dnf settings for faster downloads
CONF_FILE=/etc/dnf/dnf.conf

if ! grep -q "max_parallel_downloads=10" "${CONF_FILE}"; then
  echo "max_parallel_downloads=10" | sudo tee -a "${CONF_FILE}"
  echo "dnf downloads are now parallel!"
  echo "${LINE}"
fi

if ! grep -q "fastestmirror=True" "${CONF_FILE}"; then
  echo "fastestmirror=True" | sudo tee -a "${CONF_FILE}"
  echo "dnf downloads are now faster!"
  echo "${LINE}"
fi

# if ! grep -q 'alias dnf="dnf5"' "${HOME}/.bashrc"; then
#   echo 'alias dnf="dnf5"' | sudo tee -a ~/.bashrc
#   echo "dnf is now an alias for dnf5!"
#   echo "${LINE}"
# fi

# Update System
sudo dnf update -y
echo "${LINE}"

# Add Repositories
echo "Setting up repositories"
sudo dnf -y install dnf-plugins-core
sudo dnf copr enable cuteneko/waydroid-helper -y
echo "${LINE}"

## RPM Fusion Free & Non-free repos
fedora_version=$(rpm -E %fedora)
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${fedora_version}".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${fedora_version}".noarch.rpm -y
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1 -y

if [ ! -f /etc/yum.repos.d/home:mkittler.repo ]; then
  sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:mkittler/Fedora_"${fedora_version}"/home:mkittler.repo -y
else
  echo "Syncthing repo already exists. Skipping..."
fi
echo "${LINE}"

## Terra repo
if ! dnf repolist terra >/dev/null 2>&1; then
  sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
else
  echo "Terra repo already exists. Skipping..."
fi
echo "${LINE}"

## Login to gh cli
gh auth login -p https -h github.com -w
echo "${LINE}"

# Install Soar
curl -fsSL "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh
echo "${LINE}"

## Install dra
soar add https://github.com/devmatteini/dra/releases/download/0.10.1/dra-0.10.1-x86_64-unknown-linux-gnu.tar.gz --pkg-type archive --name dra --version 0.10.1
