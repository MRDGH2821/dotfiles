#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Update rclone
sudo rclone selfupdate

# Add Cocogitto bash completion
if type -P cog &>/dev/null; then
  mkdir -p ~/.local/share/bash-completion/completions
  cog generate-completions bash >~/.local/share/bash-completion/completions/cog
  echo "Cocogitto bash completion installed"
fi

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
