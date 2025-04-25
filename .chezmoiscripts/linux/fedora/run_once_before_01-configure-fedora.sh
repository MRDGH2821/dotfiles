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
# Install dnf5 for faster downloads & flatpak
sudo dnf install dnf5 flatpak -y
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

if ! grep -q 'alias dnf="dnf5"' "${HOME}/.bashrc"; then
  echo 'alias dnf="dnf5"' | sudo tee -a ~/.bashrc
  echo "dnf is now an alias for dnf5!"
  echo "${LINE}"
fi

# Update System
sudo dnf update -y
echo "${LINE}"

# Add Repositories
echo "Setting up repositories"
sudo dnf -y install dnf-plugins-core
echo "${LINE}"

## RPM Fusion Free & Non-free repos
fedora_version=$(rpm -E %fedora)
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${fedora_version}".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${fedora_version}".noarch.rpm -y
sudo dnf config-manager --enable fedora-cisco-openh264 -y
echo "${LINE}"

## Download dra executable
trap 'rm -fr /tmp/dra' EXIT
curl -s https://api.github.com/repos/devmatteini/dra/releases/latest | grep browser_download_url | cut -d : -f 2,3 | tr -d \" | grep linux | grep gnu | grep x86 | wget -P /tmp/dra -qi -
filename=$(ls /tmp/dra)
tarfile="${filename%.*}"
filedir="${tarfile%.*}"
tar -xvzf /tmp/dra/"${filename}" -C /tmp/dra
mkdir -p "${HOME}"/bin
cp /tmp/dra/"${filedir}"/dra "${HOME}"/bin/
rm -fr /tmp/dra

echo "${LINE}"
