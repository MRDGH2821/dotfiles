#!/usr/bin/env bash

# Disable AppArmor for firefox
sudo aa-disable /etc/apparmor.d/*firefox*

# Allow management of Docker as a non-root user
sudo groupadd docker
sudo usermod -aG docker "$USER"
newgrp docker

# Add Flathub remote
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Update rclone
sudo rclone selfupdate

# Enable Oh my posh's theme randomiser
# shellcheck disable=SC2016

omp_theme='
# Oh my posh random theme initializer

# Set a random theme
themes=($(ls ~/.cache/oh-my-posh/themes/*.json))
eval "$(oh-my-posh init bash --config "${themes[$RANDOM % ${#themes[@]}]}")"
'
if ! grep -q "$omp_theme" "$HOME/.bashrc"; then
  echo "$omp_theme" >>~/.bashrc
fi
