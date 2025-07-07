#!/usr/bin/env zsh
# shellcheck shell=bash
# Oh my posh random theme initializer
themes=(~/.cache/oh-my-posh/themes/*.json(N))

# Set a random theme if themes are available
if (( ${#themes[@]} > 0 )); then
    eval "$(oh-my-posh init zsh --config "${themes[RANDOM % ${#themes[@]}]}")"
fi
