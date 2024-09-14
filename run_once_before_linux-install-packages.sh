#!/usr/bin/env bash
set -e
LINE="-------------------------------------------"
if command -v apt &>/dev/null; then

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
  echo $LINE

  ## Waydroid
  curl https://repo.waydro.id | sudo bash
  echo $LINE

  ## Docker Engine

  sudo nala remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  ### Add the repository to Apt sources:
  # shellcheck disable=SC1091
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

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
fi
