#!/usr/bin/env bash

# XDG Base dirs
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

# shellcheck source=/dev/null
source "${HOME}/.local/share/antidot/alias.sh"
source "${HOME}/.local/share/antidot/env.sh"
