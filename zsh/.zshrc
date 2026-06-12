# ~/.zshrc (gestionado por stow desde theoffsecgirl/dotfiles)
# Toda la configuración real vive en ~/.config/zsh/load.zsh
# Este archivo es mínimo por diseño.

setopt INTERACTIVE_COMMENTS

# Carga modular completa (PATH, plugins, aliases, bug bounty, local overrides)
# Homebrew, PATH de Go y ~/.local/bin se gestionan dentro de load.zsh
if [[ -f "$HOME/.config/zsh/load.zsh" ]]; then
  source "$HOME/.config/zsh/load.zsh"
fi

# ── bun ──────────────────────────────────────────────────────────────────────
# bun install manager — mantenido aquí porque lo genera bun automáticamente
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ── Firefox profiles (Bug Bounty) ─────────────────────────────────────────────
_FF='/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox'
if [[ -x "$_FF" ]]; then
  alias ffbug="'$_FF' -P BugBounty -no-remote"
  alias fflabs="'$_FF' -P Labs -no-remote"
fi
unset _FF
