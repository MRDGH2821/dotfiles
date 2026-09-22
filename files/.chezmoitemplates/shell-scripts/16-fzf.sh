# shellcheck shell=bash
# fzf
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(fzf --"${SHELL_NAME}")" || true
