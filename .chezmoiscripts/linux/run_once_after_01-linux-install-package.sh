#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Disable AppArmor for firefox
sudo aa-disable /etc/apparmor.d/*firefox*

# Allow management of Docker as a non-root user
sudo groupadd docker
sudo usermod -aG docker "${USER}"
newgrp docker
sudo systemctl enable docker.service

# Add Flathub remote
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update rclone
sudo rclone selfupdate

# Add Cocogitto bash completition
if ! type -P cog &>/dev/null; then
  cog generate-completions bash >~/.local/share/bash-completion/completions/cog
fi
