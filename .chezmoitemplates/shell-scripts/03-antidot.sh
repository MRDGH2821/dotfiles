# shellcheck shell=bash
# antidot
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(antidot completion "${SHELL_NAME}")" || true
