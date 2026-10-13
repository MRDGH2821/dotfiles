# shellcheck shell=bash
# emplace
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(emplace init "${SHELL_NAME}")" || true
