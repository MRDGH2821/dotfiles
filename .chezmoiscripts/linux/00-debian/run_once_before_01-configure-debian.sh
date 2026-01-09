#!/usr/bin/env bash

set -e
LINE="-------------------------------------------"

export PATH="${HOME}/.local/bin:${HOME}/.local/share/soar/bin:${PATH}"

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
  if [[ ${DISTRO_VERSION} == "13" ]]; then
    echo "Running on Debian 13 (Trixie)"
  else
    echo "Warning: This script is optimized for Debian 13, but detected version ${DISTRO_VERSION}"
  fi
else
  echo "Debian-based system detected: ${DISTRO_NAME} ${DISTRO_VERSION}"
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
sudo nala fetch --auto -y --https-only --non-free
sudo nala install --update -y curl wget git ca-certificates libfuse2 gnupg2 flatpak
echo "${LINE}"

# Add Repositories
echo "Setting up repositories for ${DISTRO_NAME} ${DISTRO_VERSION}"

## Waydroid
# shellcheck disable=SC2312
curl https://repo.waydro.id | sudo bash
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
if [[ ${DISTRO_NAME} == "debian" ]] && [[ ${DISTRO_VERSION} == "13" ]]; then
  echo "Setting up Waydroid Helper repository for Debian 13..."
  echo 'deb http://download.opensuse.org/repositories/home:/CuteNeko:/waydroid-helper/Debian_13/ /' | sudo tee /etc/apt/sources.list.d/home:CuteNeko:waydroid-helper.list
  # shellcheck disable=SC2312
  curl -fsSL https://download.opensuse.org/repositories/home:CuteNeko:waydroid-helper/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_CuteNeko_waydroid-helper.gpg >/dev/null
  echo -e "Package: python3-pywayland\nPin: origin \"download.opensuse.org\"\nPin-Priority: 1001" | sudo tee /etc/apt/preferences.d/99-pywayland.pref
fi
echo "${LINE}"

## debian.griffo.io - Unofficial Repository for Latest Development Tools
# shellcheck disable=SC2312
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
# shellcheck disable=SC2312
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list

## Firefox
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null

cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

# Install Soar
# shellcheck disable=SC2312
curl -fsSL "https://raw.githubusercontent.com/pkgforge/soar/main/install.sh" | sh
echo "${LINE}"
