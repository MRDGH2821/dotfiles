#!/usr/bin/env bash
set -e
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Disable AppArmor for firefox
sudo aa-disable firefox
