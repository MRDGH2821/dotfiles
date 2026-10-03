# shellcheck shell=bash
# fnox
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(pitchfork activate "${SHELL_NAME}")" || true
