# Chezmoi
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(chezmoi completion --shell "${SHELL_NAME}")" || true
