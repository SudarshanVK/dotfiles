# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# TAB Color
# Randomly apply a TAB color
function tabcolor {
    local red=$(($(jot -r 1 128 192)))
    local green=$(($(jot -r 1 128 192)))
    local blue=$(($(jot -r 1 128 192)))
    echo -n -e "\033]6;1;bg;red;brightness;$red\a"
    echo -n -e "\033]6;1;bg;green;brightness;$green\a"
    echo -n -e "\033]6;1;bg;blue;brightness;$blue\a"
}
tabcolor

function nix-update() {
    (cd ~/dotfiles/nix && nix flake update)
}

function nix-install() {
    sudo darwin-rebuild switch --flake ~/dotfiles/nix#macos
}

# Function to create a new tmux session with a passed name
tmux_new() {
  if [ -z "$1" ]; then
    echo "Please provide a session name."
    return 1
  fi
  tmux new-session -s "$1"
}

# Function to list all tmux sessions
tmux_list() {
  tmux list-sessions
}

# Function to attach to a tmux session by name
tmux_attach() {
  if [ -z "$1" ]; then
    echo "Please provide a session name to attach."
    return 1
  fi
  tmux attach-session -t "$1"
}

# Function to kill a tmux session by name
tmux_kill() {
  if [ -z "$1" ]; then
    echo "Please provide a session name to kill."
    return 1
  fi
  tmux kill-session -t "$1"
}

# Custom clear function to preserve scrollback
clear_preserve_scrollback() {
    printf '%*s' "$(tput lines)" '' | tr ' ' '\n'
    tput cup 0 0
}

# Pyenv
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::dotenv
# zinit snippet OMZP::autoenv

# Load completions for zsh-completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Auto-pair quotes in the Zsh prompt (ZLE). Ghostty can't do this; it must be done in the shell/editor.
ghostty_autopair_quote() {
  emulate -L zsh
  setopt localoptions noshwordsplit

  local quote_char="$1"

  if [[ "${RBUFFER[1,1]}" == "${quote_char}" ]]; then
    zle forward-char
    return 0
  fi

  LBUFFER+="${quote_char}${quote_char}"
  zle backward-char
}

ghostty_autopair_single_quote() {
  ghostty_autopair_quote "'"
}

ghostty_autopair_double_quote() {
  ghostty_autopair_quote '"'
}

zle -N ghostty_autopair_single_quote
zle -N ghostty_autopair_double_quote
bindkey -M emacs "'" ghostty_autopair_single_quote
bindkey -M emacs '"' ghostty_autopair_double_quote
bindkey -M viins "'" ghostty_autopair_single_quote
bindkey -M viins '"' ghostty_autopair_double_quote

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
# setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Alias
alias code='code-insiders'
alias ls='eza --color=always --long --git --no-filesize --icons=always --no-user'
alias ll='eza --color=always --long --git --icons=always --no-filesize --group-directories-first -lah --no-user'
alias lt='eza --tree --color=always --icons=always --no-filesize'
alias li='eza --color=always --icons=always --no-filesize'
alias cat='bat --theme=gruvbox-dark'
alias c='clear'
alias clear='clear_preserve_scrollback'
alias tf='terraform'
alias tfi='terraform init'
alias tfiu='terraform init -upgrade'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias record='asciinema rec'
alias play='asciinema play'
alias upload='asciinema upload'
alias cd='z'
alias zz='zed'
alias e="/Applications/Windsurf.app/Contents/MacOS/Electron"
alias dc='docker compose'
alias ap='ansible-playbook'
alias ag='ansible-galaxy'
alias gc='aicommit2'
alias ga='git add .'
alias gp='git push'
# Tmux aliases
alias tnew='tmux_new'; ; alias tn='tmux_new'
alias tlist='tmux_list'; alias tl='tmux_list'
alias tattach='tmux_attach'; alias ta='tmux_attach'
alias tkill='tmux_kill'; alias tk='tmux_kill'
alias lgit='lazygit'

source <(kubectl completion zsh)
alias k=kubectl
alias kx='kubectx'
alias k3s='kubectl --kubeconfig ~/kubeconfigs/k3s-home.yaml'
alias specify="uvx --from git+https://github.com/github/spec-kit.git specify init"
alias trestart='tmux source-file ~/.tmux.conf && echo "✅ Tmux config reloaded"'


export JAVA_HOME=$(/usr/libexec/java_home -v17)
export PATH="$JAVA_HOME/bin:$PATH"

# SSH key
ssh-add ~/.ssh/id_rsa

# fzf
source <(fzf --zsh)
# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}
# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

#! to remove the ESC characters when doing | less for anything
export LESS=eFRX
# export TERM=xterm-256color

# Kube config file
export KUBECONFIG=~/.kube/home:~/.kube/eks:~/.kube/rancher:~/.kube/config

# Zoxide
eval "$(zoxide init zsh)"

# Window title function for iTerm2
function set_win_title(){
    if [[ -r "$PWD" ]]; then
        echo -ne "\033]0; $(basename "$PWD") \007"
    else
        echo -ne "\033]0; Terminal \007"
    fi
}
precmd_functions+=(set_win_title)

#starship
eval "$(starship init zsh)"
source /Users/sudarshanv/.config/op/plugins.sh
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sudarshanv/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

fpath+=~/.zfunc; autoload -Uz compinit; compinit


if [[ -d ~/dotfiles/.shell_functions ]]; then
    for file in ~/dotfiles/.shell_functions/*.sh; do
        if [[ -f "$file" ]]; then
            echo "Loading shell function: $file"
            source "$file"
        fi
    done
fi

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Custom atuin keybindings
# Ctrl+R to open atuin search
bindkey '^r' atuin-search
# Disable up arrow for atuin (use normal shell history navigation)
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history

# Ghostty
export XDG_CONFIG_HOME="$HOME/dotfiles/.config"
export PATH="$HOME/bin:$PATH"
source /etc/variables/openai.env
export NODE_OPTIONS="--no-deprecation"

export NVM_DIR="$HOME/dotfiles/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
