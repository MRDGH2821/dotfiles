#!/usr/bin/env bash

# Fast Node Manager
FNM_PATH="${HOME}/.local/share/fnm"
if [[ -d ${FNM_PATH} ]]; then
  export PATH="${FNM_PATH}:${PATH}"
  eval "$(fnm env)" || true
fi
