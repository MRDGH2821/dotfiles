# shellcheck shell=bash
# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
  if test -r ~/.dircolors; then
    eval "$(dircolors -b ~/.dircolors)" || true
  else
    eval "$(dircolors -b)" || true
  fi
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Miscellaneous Aliases
alias dnf="dnf5"
alias tb="nc termbin.com 9999"
alias tf='touchfile'
alias cat='bat --paging=never'

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

touchfile() {
  mkdir -p "$(dirname "$1")" && touch "$1" && echo "$1"
}

line() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '-'
}

update-repo() {
  local repo_dir="${1:-.}"

  line
  echo "→ Updating repo: $(basename "${repo_dir}")"
  line

  # Git pull
  git -C "${repo_dir}" pull

  # Copier template update
  if [[ -f "${repo_dir}/.copier-answers.yml" ]] || [[ -f "${repo_dir}/.copier-answers.yaml" ]]; then
    line
    echo "• Copier template..."
    (cd "${repo_dir}" && copier update)
  fi

  # Python dependencies (uv)
  if [[ -f "${repo_dir}/uv.lock" ]]; then
    line
    echo "• Python dependencies (uv)..."
    (cd "${repo_dir}" && uv-upx upgrade run)
  fi

  # Rust dependencies (cargo)
  if [[ -f "${repo_dir}/Cargo.lock" ]]; then
    line
    echo "• Rust dependencies (cargo)..."
    (cd "${repo_dir}" && cargo update)
  fi

  # JS/TS dependencies (bun)
  if [[ -f "${repo_dir}/bun.lock" ]] || [[ -f "${repo_dir}/bun.lockb" ]]; then
    line
    echo "• JS dependencies (bun)..."
    (cd "${repo_dir}" && bun update)
  fi

  # Go dependencies
  if [[ -f "${repo_dir}/go.sum" ]]; then
    line
    echo "• Go dependencies..."
    (cd "${repo_dir}" && go get -u ./... && go mod tidy)
  fi

  # Nix flake updates
  if [[ -f "${repo_dir}/flake.lock" ]]; then
    line
    echo "• Nix flake updates..."
    (cd "${repo_dir}" && nix flake update)
  fi

  # Skills (agent skills update)
  if [[ -f "${repo_dir}/skills-lock.json" ]]; then
    line
    echo "• Skills update..."
    (cd "${repo_dir}" && bun x skills update -p -y)
  fi

  # Compose updater
  if command -v ccu >/dev/null 2>&1; then
    line
    echo "• Compose updater..."
    (cd "${repo_dir}" && ccu -f -u)
  fi

  # GitHub Actions updater
  if [[ -d "${repo_dir}/.github/workflows/" ]]; then
    line
    echo "• GitHub Actions updater..."
    (cd "${repo_dir}" && bunx actions-up@latest -r)
  fi

  line
  echo "✓ Repo update complete"
  line
}

# Conditional aliases

if command -v zeditor >/dev/null 2>&1; then
  alias zed='zeditor'
fi

# Bun

alias bunx="bun x"
