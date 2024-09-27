#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Disable AppArmor for firefox
sudo aa-disable firefox || true
