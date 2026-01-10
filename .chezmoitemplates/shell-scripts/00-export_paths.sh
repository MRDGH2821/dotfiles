# bin
export PATH="${HOME}/.local/bin:${PATH}"

# soar
export PATH="${HOME}/.local/share/soar/bin:${PATH}"

# fnm
FNM_PATH="${HOME}/.local/share/fnm"
if [[ -d ${FNM_PATH} ]]; then
  export PATH="${FNM_PATH}:${PATH}"
fi

# cargo
export PATH="${HOME}/.cargo/bin:${PATH}"

# bun
export PATH="${HOME}/.cache/.bun/bin:${PATH}"
