#!/usr/bin/env bats
# tests/test_zsh.bats — smoke tests para configuración zsh
# Requiere zsh instalado. Ejecutar con: bats tests/test_zsh.bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  TMP_HOME="$(mktemp -d)"
  # Simular HOME limpio con estructura mínima de stow
  mkdir -p "$TMP_HOME/.config/zsh"
  mkdir -p "$TMP_HOME/.dotfiles"
  cp -r "$REPO_ROOT/vendor" "$TMP_HOME/.dotfiles/vendor"
  cp -r "$REPO_ROOT/zsh/.config/zsh"/* "$TMP_HOME/.config/zsh/"
  export DOTFILES_DIR="$TMP_HOME/.dotfiles"
  export HOME="$TMP_HOME"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "load.zsh se puede sourcear sin errores de sintaxis" {
  run zsh -n "$HOME/.config/zsh/load.zsh"
  [ "$status" -eq 0 ]
}

@test "aliases-builtin.zsh sintaxis válida" {
  run zsh -n "$HOME/.dotfiles/vendor/shell-utils/zsh/aliases-builtin.zsh"
  [ "$status" -eq 0 ]
}

@test "aliases-bugbounty.zsh sintaxis válida" {
  run zsh -n "$HOME/.dotfiles/vendor/shell-utils/zsh/aliases-bugbounty.zsh"
  [ "$status" -eq 0 ]
}

@test "functions-bugbounty.zsh sintaxis válida" {
  run zsh -n "$HOME/.dotfiles/vendor/shell-utils/zsh/functions-bugbounty.zsh"
  [ "$status" -eq 0 ]
}

@test "bug-bounty.zsh sintaxis válida" {
  run zsh -n "$HOME/.config/zsh/bug-bounty.zsh"
  [ "$status" -eq 0 ]
}

@test "wrapper-exegol.zsh sintaxis válida" {
  run zsh -n "$HOME/.dotfiles/vendor/shell-utils/zsh/wrapper-exegol.zsh"
  [ "$status" -eq 0 ]
}

@test "PLATFORM se define al sourcear aliases-builtin" {
  run zsh -c "
    source '$HOME/.dotfiles/vendor/shell-utils/zsh/aliases-builtin.zsh'
    [[ -n \"\$PLATFORM\" ]]
  "
  [ "$status" -eq 0 ]
}
