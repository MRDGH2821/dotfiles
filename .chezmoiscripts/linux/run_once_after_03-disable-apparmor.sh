#!/usr/bin/env bash
set -e

export PATH="${HOME}/.local/bin:${PATH}"

# Disable AppArmor for firefox
sudo aa-disable firefox

echo "Firefox AppArmor script executed."
