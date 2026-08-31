#!/usr/bin/env bats
# test/test_dotfiles-ref.bats — verifica la salud básica del cheatsheet dotfiles-ref.zsh.
# Ejecutar con: bats test/test_dotfiles-ref.bats
#
# El check de drift entre scripts/.local/bin/ y dotfiles-ref.zsh se retiró:
# scripts/ ya no vive en este repo (migrado a bugbounty-toolkit con su
# historial vía git subtree split). dotfiles-ref.zsh se conserva aquí como
# cheatsheet de referencia para los comandos que instala ese otro repo.

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DOTFILES_REF="$REPO_ROOT/config/.config/zsh/dotfiles-ref.zsh"
}

@test "dotfiles-ref.zsh tiene sintaxis zsh válida" {
  run zsh -n "$DOTFILES_REF"
  [ "$status" -eq 0 ]
}

@test "program-import-brief tiene entrada en dotfiles-ref.zsh" {
  grep -q '"program-import-brief"' "$DOTFILES_REF"
}

@test "tmux-recon tiene entrada en dotfiles-ref.zsh" {
  grep -q '"tmux-recon"' "$DOTFILES_REF"
}
