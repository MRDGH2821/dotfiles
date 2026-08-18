# shellcheck shell=bash
# direnv
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(mise activate "${SHELL_NAME}")" || true
