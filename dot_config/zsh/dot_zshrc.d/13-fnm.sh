#!/usr/bin/env zsh
# shellcheck shell=bash
# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

if [[ -f .node-version || -f .nvmrc ]]; then
	fnm use
fi
