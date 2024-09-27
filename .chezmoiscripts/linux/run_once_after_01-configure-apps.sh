#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Update rclone
sudo rclone selfupdate

# Add Cocogitto bash completition
if ! type -P cog &>/dev/null; then
  cog generate-completions bash >~/.local/share/bash-completion/completions/cog
fi

# Install Nerd font
oh-my-posh font install meslo

exit 0
