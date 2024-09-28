#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Allow management of Docker as a non-root user
sudo groupadd docker -f
sudo usermod -aG docker "${USER}"
sudo systemctl enable docker.service

echo "Docker is now managable by ${USER}"
echo "Please reboot once for changes to take effect"
