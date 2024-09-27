#!/usr/bin/env bash
# shellcheck disable=SC2312
set -e
LINE="-------------------------------------------"

if command -v apt &>/dev/null; then
  echo "Debian based system found!"
  # Install Nala
  if command -v nala &>/dev/null; then
    echo "Nala is already installed. Skipping"
  else
    curl https://gitlab.com/volian/volian-archive/-/raw/main/install-nala.sh | bash
    sudo apt install -t nala nala
  fi

  # Setup Nala
  sudo nala fetch --auto -y --https-only --non-free
  sudo nala install --update -y curl wget git ca-certificates libfuse2 gnupg2

  # Add Repositories
  echo "Setting up repositories"

  ## KeePassXC
  sudo add-apt-repository ppa:phoerious/keepassxc -y
  echo "${LINE}"

  ## Waydroid
  curl https://repo.waydro.id | sudo bash
  echo "${LINE}"

  ## Docker Engine

  sudo nala remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  ### Add the repository to Apt sources:
  # shellcheck disable=SC1091
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  ## Fastfetch
  sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y

  ## GitHub CLI
  sudo mkdir -p -m 755 /etc/apt/keyrings
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  ## OneDrive CLI
  sudo nala remove onedrive -y
  sudo add-apt-repository --remove ppa:yann1ck/onedrive
  wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg >/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list

elif command -v dnf &>/dev/null; then

  # Install dnf5 for faster downloads
  sudo dnf install dnf5

  # modify dnf settings for faster downloads
  CONF_FILE=/etc/dnf/dnf.conf

  if ! grep -q "max_parallel_downloads=10" "${CONF_FILE}"; then
    echo "max_parallel_downloads=10" | sudo tee -a "${CONF_FILE}"
    echo "dnf downloads are now parallel!"
  fi

  if ! grep -q "fastestmirror=True" "${CONF_FILE}"; then
    echo "fastestmirror=True" | sudo tee -a "${CONF_FILE}"
    echo "dnf downloads are now faster!"
  fi

  if ! grep -q "alias dnf=\"dnf5\"" "${HOME}/.bashrc"; then
    echo "alias dnf=\"dnf5\"" | sudo tee -a ~/.bashrc
    echo "dnf is now an alias for dnf5!"
  fi

  # Update System
  sudo dnf update -y

  # Add Repositories
  echo "Setting up repositories"
  sudo dnf -y install dnf-plugins-core

  ## Docker Engine
  sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

  ## RPM Fusion Free & Non-free repos
  fedora_version=$(rpm -E %fedora)
  sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$fedora_version".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$fedora_version".noarch.rpm -y
  sudo dnf config-manager --enable fedora-cisco-openh264 -y

  ## Download dra executable
  curl -s https://api.github.com/repos/devmatteini/dra/releases/latest | grep browser_download_url | cut -d : -f 2,3 | tr -d \" | grep linux | grep gnu | grep x86 | wget -P /tmp/dra -qi -
  filename=$(ls /tmp/dra)
  filedir="${filename%.*}"
  tar -xvzf "$filename" -C /tmp/dra
  mkdir -p "$HOME"/bin
  cp "$filedir"/dra "$HOME"/bin/
  rm -fr /tmp/dra

else
  echo "Nothing to do on non unknown systems"
fi
