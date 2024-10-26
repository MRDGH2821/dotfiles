#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"

# Update rclone
sudo rclone selfupdate

# Add Cocogitto bash completition
if type -P cog &>/dev/null; then
  mkdir -p ~/.local/share/bash-completion/completions
  cog generate-completions bash >~/.local/share/bash-completion/completions/cog
  echo "Cocogitto bash completition installed"
fi

# Install Nerd font
oh-my-posh font install meslo
oh-my-posh enable autoupgrade

# Install ggshield global precommit hook
ggshield install -m global

# Set gh as default git credentials helper
gh auth setup-git
