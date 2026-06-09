# shellcheck shell=bash
# uv
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(uv --generate-shell-completion "${SHELL_NAME}")" || true
eval "$(uvx --generate-shell-completion "${SHELL_NAME}")" || true
