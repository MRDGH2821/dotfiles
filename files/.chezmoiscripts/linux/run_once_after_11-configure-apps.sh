#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${PATH}"

# Install Nerd font
oh-my-posh font install meslo
oh-my-posh enable upgrade

# Set gh as default git credentials helper
gh auth setup-git

# Add espanso capabilities
ESPANSO_PATH=$(command -v espanso)
sudo setcap "cap_dac_override+p" "${ESPANSO_PATH}"
