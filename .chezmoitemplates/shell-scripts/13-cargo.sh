# shellcheck shell=bash
# cargo
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(rustup completions "${SHELL_NAME}" cargo)" || true
export PATH="${HOME}/.cargo/bin:${PATH}"
