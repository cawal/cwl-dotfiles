# Setup fzf
# ---------
# NixOS: fzf is installed system-wide via nixpkgs

# Auto-completion
# ---------------
if [ -f /run/current-system/sw/share/fzf/completion.zsh ]; then
  source /run/current-system/sw/share/fzf/completion.zsh
fi

# Key bindings
# ------------
if [ -f /run/current-system/sw/share/fzf/key-bindings.zsh ]; then
  source /run/current-system/sw/share/fzf/key-bindings.zsh
fi

# Ctrl+R - Search command history
# Ctrl+T - Search files
# Alt+C  - Change directory
