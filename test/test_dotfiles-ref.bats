#!/usr/bin/env bats
# test/test_dotfiles-ref.bats — verifica la salud básica del cheatsheet dotfiles-ref.zsh.
# Ejecutar con: bats test/test_dotfiles-ref.bats
#
# dotfiles-ref.zsh cubre únicamente utilidades genéricas de este repo. El
# pipeline de bug bounty (recon, hunt-ai, etc.) vive en el repo separado
# bugbounty-toolkit y no tiene entradas aquí.

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DOTFILES_REF="$REPO_ROOT/config/.config/zsh/dotfiles-ref.zsh"
}

@test "dotfiles-ref.zsh tiene sintaxis zsh válida" {
  run zsh -n "$DOTFILES_REF"
  [ "$status" -eq 0 ]
}

@test "mkproject tiene entrada en dotfiles-ref.zsh" {
  grep -q '"mkproject"' "$DOTFILES_REF"
}

@test "tmux-sessionizer tiene entrada en dotfiles-ref.zsh" {
  grep -q '"tmux-sessionizer"' "$DOTFILES_REF"
}

@test "dotfiles-ref.zsh no referencia comandos migrados a bugbounty-toolkit" {
  ! grep -qE '"(program-import-brief|scope-program|webmap|paramhunt-v2|hunt-ai|hunt-doctor|nmap-scope)"' "$DOTFILES_REF"
}
