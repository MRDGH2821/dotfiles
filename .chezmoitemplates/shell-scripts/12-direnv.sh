# direnv
SHELL_PATH=$(ps -p $$ -o comm=)
SHELL_NAME=$(basename "${SHELL_PATH}")

eval "$(direnv hook "${SHELL_NAME}")" || true
# This is a workaround to make direnv work with VS Code's integrated terminal
# when using the direnv extension, by making sure to reload
# the environment the first time the terminal is opened.
#
# See https://github.com/direnv/direnv-vscode/issues/561#issuecomment-1837462994.
#
# The variable VSCODE_INJECTION is apparently set by VS Code itself, and this is how
# we can detect if we're running inside the VS Code terminal or not.
# This solution works in combination with setting the PATH_BACKUP_FOR_VSCODE within the .envrc file after `use flake`

if [[ -n "${VSCODE_INJECTION}" && -n "${PATH_BACKUP_FOR_VSCODE}" && -z "${VSCODE_TERMINAL_DIRENV_LOADED}" && -f .envrc ]]; then
  export PATH=${PATH_BACKUP_FOR_VSCODE}
  export VSCODE_TERMINAL_DIRENV_LOADED=1
fi
