#!/usr/bin/env bash
set -e

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v aa-status &>/dev/null; then
  echo "AppArmor is not installed."
  exit 0
fi

# Disable AppArmor for firefox
sudo aa-disable firefox

echo "Firefox AppArmor script executed."
