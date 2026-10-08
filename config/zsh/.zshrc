# Vymrland interactive zsh.
#
# Login shell stays bash (Omarchy default). This file is only read when zsh
# runs interactively; ~/.zshenv points ZDOTDIR here.

# Omarchy environment (OMARCHY_PATH, PATH). Bash-style file, safe to source.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# History
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY INC_APPEND_HISTORY

# Shell behaviour
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS

# Prompt
command -v starship >/dev/null && eval "$(starship init zsh)"

# Directory jumping
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# fzf keybindings + completion
if command -v fzf >/dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
fi

# Aliases
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias grep='rg'
alias lg='lazygit'

# Auto-start tmux in Ghostty terminals (ported from ~/.bashrc). Skipped when
# already inside tmux or a nested shell. Remove this block to use zellij
# manually instead.
if [[ -z $TMUX && -z $OMARCHY_AUTO_TMUX && $TERM_PROGRAM == ghostty ]]; then
  export OMARCHY_AUTO_TMUX=1
  tmux new-session -A -s main
fi
