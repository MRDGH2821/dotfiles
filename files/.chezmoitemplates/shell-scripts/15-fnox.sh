# shellcheck shell=bash
# fnox
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(fnox activate "${SHELL_NAME}")" || true
