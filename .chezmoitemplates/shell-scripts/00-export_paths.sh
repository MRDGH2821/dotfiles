# shellcheck shell=bash

# XDG Base dirs
eval "$(antidot init)" || true

export XDG_STATE_HOME="${HOME}/.local/state"

# XDG folders
export HISTFILE="${XDG_STATE_HOME}"/shell/history

# bin
export PATH="${HOME}/.local/bin:${PATH}"

# soar
export PATH="${XDG_DATA_HOME}/soar/bin:${PATH}"

# fnm
FNM_PATH="${XDG_DATA_HOME}/fnm"
if [[ -d ${FNM_PATH} ]]; then
  export PATH="${FNM_PATH}:${PATH}"
fi

# cargo
export PATH="${CARGO_HOME}/bin:${PATH}"

# bun
export PATH="${HOME}/.cache/.bun/bin:${PATH}"

# Default Apps
export EDITOR="nano"
export VISUAL="zed"
export PAGER="less"
