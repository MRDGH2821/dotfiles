#!/usr/bin/env zsh
# shellcheck shell=bash
# UV
eval "$(uv --generate-shell-completion zsh)" || true
eval "$(uvx --generate-shell-completion zsh)" || true
