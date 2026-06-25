# shellcheck shell=bash

# AppImages
export PATH="${HOME}/AppImages:${PATH}"

# XDG Base dirs

export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

# soar
export PATH="${XDG_DATA_HOME:-${HOME}/.local/share}/soar/bin:${PATH}"

# antidot

eval "$(antidot init)" || true

# XDG folders
export HISTFILE="${XDG_STATE_HOME}"/shell/history

# bin
export PATH="${HOME}/.local/bin:${PATH}"

# fnm
FNM_PATH="${XDG_DATA_HOME:-${HOME}/.local/share}/fnm"
if [[ -d ${FNM_PATH} ]]; then
  export PATH="${FNM_PATH}:${PATH}"
fi

# cargo
export PATH="${CARGO_HOME}/bin:${PATH}"

# bun
export PATH="${HOME}/.cache/.bun/bin:${PATH}"

# Default Apps
export EDITOR="zed --wait"
export VISUAL="zed --wait"
export PAGER="less"
