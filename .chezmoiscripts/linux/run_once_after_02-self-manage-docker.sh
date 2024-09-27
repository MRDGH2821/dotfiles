#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Allow management of Docker as a non-root user
sudo groupadd docker -f
sudo usermod -aG docker "${USER}"
newgrp docker
sudo systemctl enable docker.service
