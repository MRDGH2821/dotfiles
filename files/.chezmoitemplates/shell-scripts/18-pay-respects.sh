# shellcheck shell=bash
# pay-respects
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(pay-respects "${SHELL_NAME}" --alias)" || true
