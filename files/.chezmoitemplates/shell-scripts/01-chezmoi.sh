# shellcheck shell=bash
# Chezmoi
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(chezmoi completion "${SHELL_NAME}")" || true
