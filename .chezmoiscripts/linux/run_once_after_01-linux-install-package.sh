#!/usr/bin/env bash

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
