#!/usr/bin/env bash
set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${PATH}"

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
sudo dnf copr enable cuteneko/waydroid-helper
echo "${LINE}"

## RPM Fusion Free & Non-free repos
fedora_version=$(rpm -E %fedora)
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${fedora_version}".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${fedora_version}".noarch.rpm -y
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
echo "${LINE}"

## Login to gh cli
gh auth login -p https -h github.com -w

## Download dra executable
trap 'rm -fr /tmp/dra' EXIT
mkdir -p /tmp/dra
gh release download --repo devmatteini/dra --pattern '*linux*gnu*x86*.tar.gz' --dir /tmp/dra
filename=$(ls /tmp/dra/*.tar.gz)
tarfile="${filename%.*}"
filedir="${tarfile%.*}"
tar -xvzf "${filename}" -C /tmp/dra
mkdir -p "${HOME}"/.local/bin
cp /tmp/dra/"${filedir}"/dra "${HOME}"/.local/bin/
rm -fr /tmp/dra

echo "${LINE}"
