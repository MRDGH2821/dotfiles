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

# Conditional aliases

if type -P zeditor >/dev/null 2>&1; then
  alias zed='zeditor'
fi
