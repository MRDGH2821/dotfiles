# shellcheck shell=bash
# cargo
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

if [[ "${SHELL_NAME}" == "zsh" ]] && command -v rustc >/dev/null 2>&1; then
  # zsh: don't `source` the rustup _cargo file — it ends with a bare
  # `_cargo` call that runs `_arguments` outside a completion context
  # and triggers `_arguments:comparguments:327: can only be called from
  # completion function`. Instead, register it for autoload on fpath.
  RUST_ZSH_FUNCTIONS="$(rustc --print sysroot)/share/zsh/site-functions"
  if [[ -d "${RUST_ZSH_FUNCTIONS}" ]]; then
    # shellcheck disable=SC2206
    fpath=("${RUST_ZSH_FUNCTIONS}" ${fpath})
    autoload -Uz _cargo
    compdef _cargo cargo
  fi
else
  # bash: rustup's bash completion is eager-safe
  eval "$(rustup completions "${SHELL_NAME}" cargo)" || true
fi
export PATH="${HOME}/.cargo/bin:${PATH}"
