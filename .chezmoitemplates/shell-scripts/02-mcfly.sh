# mcfly
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(mcfly init "${SHELL_NAME}")" || true
