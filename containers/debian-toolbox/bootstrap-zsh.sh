#!/usr/bin/env bash
set -euo pipefail

mkdir -p /root/.config/zsh /root/.local/bin /root/go/bin

ln -sf /root/.dotfiles/zsh/.config/zsh/load.zsh /root/.config/zsh/load.zsh
ln -sf /root/.dotfiles/zsh/.config/zsh/bug-bounty.zsh /root/.config/zsh/bug-bounty.zsh
ln -sf /root/.dotfiles/scripts/.local/bin/* /root/.local/bin/ || true

cat > /root/.zshrc <<'ZEOF'
export OFFSEC_CONTAINER=1
export HUNTING_HOME=/work
export PATH="/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"
[[ -f "$HOME/.config/zsh/load.zsh" ]] && source "$HOME/.config/zsh/load.zsh"
ZEOF

exec /usr/bin/zsh -l
