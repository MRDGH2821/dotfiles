# shellcheck shell=bash
# Fast Node Manager
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")
FNM_PATH="${HOME}/.local/share/fnm"

if [[ -d ${FNM_PATH} ]]; then
  export PATH="${FNM_PATH}:${PATH}"
fi

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell "${SHELL_NAME}")" || true

  if [[ -f .node-version ]] || [[ -f .nvmrc ]]; then
    fnm use || true
  fi
fi
