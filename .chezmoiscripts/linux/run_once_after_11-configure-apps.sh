#!/usr/bin/env bash

export PATH="${HOME}/.local/bin:${PATH}"

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

# Add Zed editor symlink
if ! command -v zed >/dev/null 2>&1; then
  ln -s "$(command -v zeditor)" "${HOME}/.local/bin/zed"
fi
