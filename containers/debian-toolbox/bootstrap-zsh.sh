#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/.config/zsh /root/.local/bin

ln -sf /root/.dotfiles/zsh/.config/zsh/load.zsh /root/.config/zsh/load.zsh
ln -sf /root/.dotfiles/zsh/.config/zsh/bug-bounty.zsh /root/.config/zsh/bug-bounty.zsh
ln -sf /root/.dotfiles/scripts/.local/bin/* /root/.local/bin/ || true

cat > /root/.zshrc <<'ZEOF'
[[ -f "$HOME/.config/zsh/load.zsh" ]] && source "$HOME/.config/zsh/load.zsh"
export PATH="/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"
ZEOF

exec /usr/bin/zsh -l
