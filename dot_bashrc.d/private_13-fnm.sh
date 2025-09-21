#!/usr/bin/env bash
# shellcheck shell=bash
# fnm
eval "$(fnm env --use-on-cd --shell bash)"

if [[ -f .node-version || -f .nvmrc ]]; then
	fnm use
fi
