#!/usr/bin/env bash

# Oh my posh random theme initializer
mapfile -t themes < <(ls ~/.cache/oh-my-posh/themes/*.json) || true

# Set a random theme
eval "$(oh-my-posh init bash --config "${themes[RANDOM % ${#themes[@]}]}")" || true
