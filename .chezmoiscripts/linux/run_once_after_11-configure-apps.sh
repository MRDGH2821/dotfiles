#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${PATH}"

# Update rclone
sudo rclone selfupdate

# Install Nerd font
oh-my-posh font install meslo
oh-my-posh enable upgrade

# Install ggshield global precommit hook
ggshield install -m global

# Set gh as default git credentials helper
gh auth setup-git

# Add espanso capabilities
ESPANSO_PATH=$(command -v espanso)
sudo setcap "cap_dac_override+p" "${ESPANSO_PATH}"
