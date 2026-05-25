# ~/.zshrc (gestionado por stow desde theoffsecgirl/dotfiles)
setopt INTERACTIVE_COMMENTS
# Carga todo desde ~/.config/zsh/load.zsh
if [[ -f "$HOME/.config/zsh/load.zsh" ]]; then
  source "$HOME/.config/zsh/load.zsh"
fi

# bun completions
[ -s "/Users/theoffsecgirl/.bun/_bun" ] && source "/Users/theoffsecgirl/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Alias Perfiles BB
alias ffbug='/Applications/Firefox\ Developer\ Edition.app/Contents/MacOS/firefox -P BugBounty -no-remote'
alias fflabs='/Applications/Firefox\ Developer\ Edition.app/Contents/MacOS/firefox -P Labs -no-remote'
export PATH="$HOME/.local/bin:$PATH"
