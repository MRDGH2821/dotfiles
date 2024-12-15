# Install ggshield global precommit hook
ggshield install -m global

# Install Nerd font
oh-my-posh font install meslo
oh-my-posh enable autoupgrade

# Set gh as default git credentials helper
gh auth setup-git

# Disable Rye global shims
rye config --set-bool behavior.global-python=false
