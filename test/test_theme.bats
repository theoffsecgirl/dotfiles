#!/usr/bin/env bats
# test/test_theme.bats — smoke tests del selector de temas (bin/.local/bin/theme)
# Ejecutar con: bats test/test_theme.bats

setup() {
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  THEME_BIN="$REPO_ROOT/bin/.local/bin/theme"
  TMP_HOME="$(mktemp -d)"
  mkdir -p "$TMP_HOME/.config/ghostty" "$TMP_HOME/.config/fastfetch"
  cp -r "$REPO_ROOT/config/.config/themes" "$TMP_HOME/.config/themes"
  cp "$REPO_ROOT/config/.config/starship.toml" "$TMP_HOME/.config/starship.toml"
  cp "$REPO_ROOT/config/.config/ghostty/config" "$TMP_HOME/.config/ghostty/config"
  cp "$REPO_ROOT/config/.config/fastfetch/config.jsonc" "$TMP_HOME/.config/fastfetch/config.jsonc"
  export HOME="$TMP_HOME"
  unset XDG_CONFIG_HOME XDG_STATE_HOME TMUX
  STATE="$HOME/.local/state/theme"
}

teardown() {
  rm -rf "$TMP_HOME"
}

@test "theme tiene sintaxis bash válida" {
  run bash -n "$THEME_BIN"
  [ "$status" -eq 0 ]
}

@test "theme.zsh tiene sintaxis zsh válida" {
  run zsh -n "$REPO_ROOT/config/.config/zsh/theme.zsh"
  [ "$status" -eq 0 ]
}

@test "todos los temas definen las variables necesarias y se aplican" {
  for t in $("$THEME_BIN" names); do
    run "$THEME_BIN" set "$t"
    [ "$status" -eq 0 ] || { echo "falla: $t — $output"; return 1; }
  done
}

@test "hay al menos 5 temas, incluido neon-fuchsia" {
  run "$THEME_BIN" names
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | wc -l)" -ge 5 ]
  printf '%s\n' "$output" | grep -qx 'neon-fuchsia'
}

@test "theme set genera los ficheros de todas las apps" {
  run "$THEME_BIN" set trick-or-treat
  [ "$status" -eq 0 ]
  for f in current env.zsh ghostty starship.toml fastfetch.jsonc tmux.conf nvim.lua; do
    [ -s "$STATE/$f" ] || { echo "falta $f"; return 1; }
  done
  [ "$(cat "$STATE/current")" = "trick-or-treat" ]
  [ -f "$HOME/.config/ghostty/current-theme.local" ]
  grep -q '^background = 110c14' "$HOME/.config/ghostty/current-theme.local"
}

@test "la config de starship generada usa la paleta del tema" {
  "$THEME_BIN" set pumpkin-spice
  grep -q '^palette = "theme"' "$STATE/starship.toml"
  grep -q '^\[palettes.theme\]' "$STATE/starship.toml"
  ! grep -q 'neon_fuchsia' "$STATE/starship.toml"
}

@test "un tema inexistente da error" {
  run "$THEME_BIN" set no-existe
  [ "$status" -ne 0 ]
}

@test "theme reset vuelve a neon-fuchsia" {
  "$THEME_BIN" set witching-hour
  "$THEME_BIN" reset
  [ "$("$THEME_BIN" current)" = "neon-fuchsia" ]
}

@test "theme tiene entrada en dotfiles-ref.zsh" {
  grep -q '"theme"' "$REPO_ROOT/config/.config/zsh/dotfiles-ref.zsh"
}
