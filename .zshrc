export TERMINFO_DIRS="$HOME/.terminfo:/usr/share/terminfo" 
# PATH
export PATH="$HOME/.bun/bin:$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$HOME/.local/share/nvim-linux-x86_64/bin:$HOME/.cargo/bin:$HOME/.pixi/bin:$HOME/.fzf/bin:$HOME/software/neovim/build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"


# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# starship
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:-1,bg:-1,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:-1 \
--color=border:-1,label:#CDD6F4 \
--preview-window='border-none'"


show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# Better ls eza
alias ls="eza --icons=always"
alias ll="eza --color=always --long --git"
alias mx="cmatrix -s -u 10"
alias vtop="vtop --theme catppuccin-mocha-peach"
alias clash-on='source ~/software/clash/clash_proxy.sh start'
alias clash-off='source ~/software/clash/clash_proxy.sh stop'
alias clash-restart='source ~/software/clash/clash_proxy.sh restart'
alias clash-status='source ~/software/clash/clash_proxy.sh status'
alias ta="tmux attach"
alias tn="tmux new -s"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# Pixi Autocompletion
autoload -Uz compinit && compinit  # redundant with Oh My Zsh
eval "$(pixi completion --shell zsh)"

source ~/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh


# opencode
export PATH=/home/liulab/shanhanjie//.opencode/bin:$PATH
export CPC_HOME=$HOME/software/CPC2_standalone-1.0.1
export PATH=$CPC_HOME/bin:$PATH
