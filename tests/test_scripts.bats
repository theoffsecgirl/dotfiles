#!/usr/bin/env bats
# tests/test_scripts.bats — smoke tests para scripts/.local/bin/
# Ejecutar con: bats tests/test_scripts.bats

setup() {
  # Directorio raz del repo (un nivel arriba de tests/)
  REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  BIN="$REPO_ROOT/scripts/.local/bin"
  TMP_DIR="$(mktemp -d)"
  export HOME="$TMP_DIR"
}

teardown() {
  rm -rf "$TMP_DIR"
}

# ------------------------------------------------
# jwt-decode
# ------------------------------------------------
@test "jwt-decode: muestra uso sin argumentos" {
  run "$BIN/jwt-decode"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "jwt-decode: decodifica un JWT real" {
  # JWT con payload {\"sub\":\"test\",\"iat\":1}
  TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0IiwiaWF0IjoxfQ.signature"
  run bash "$BIN/jwt-decode" "$TOKEN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"sub"* ]]
  [[ "$output" == *"test"* ]]
}

# ------------------------------------------------
# fuzzdirs
# ------------------------------------------------
@test "fuzzdirs: falla sin argumentos" {
  run bash "$BIN/fuzzdirs"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "fuzzdirs: falla si WORDLISTS no definida" {
  unset WORDLISTS 2>/dev/null || true
  run bash "$BIN/fuzzdirs" "example.com"
  [ "$status" -eq 1 ]
  [[ "$output" == *"WORDLISTS"* ]]
}

@test "fuzzdirs: falla si wordlist no existe" {
  export WORDLISTS="/tmp/wordlists_inexistente_$$"
  run bash "$BIN/fuzzdirs" "example.com"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No se encontró"* ]]
}

# ------------------------------------------------
# paramhunt
# ------------------------------------------------
@test "paramhunt: falla sin argumentos" {
  run bash "$BIN/paramhunt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "paramhunt: falla si urls.txt no existe" {
  run bash "$BIN/paramhunt" "target.com"
  [ "$status" -eq 1 ]
  [[ "$output" == *"scope"* || "$output" == *"No se encontró"* ]]
}

# ------------------------------------------------
# webmap
# ------------------------------------------------
@test "webmap: falla sin argumentos" {
  run bash "$BIN/webmap"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "webmap: falla si live.txt no existe" {
  run bash "$BIN/webmap" "target.com"
  [ "$status" -eq 1 ]
  [[ "$output" == *"scope"* || "$output" == *"No se encontró"* ]]
}

# ------------------------------------------------
# race-run
# ------------------------------------------------
@test "race-run: falla sin argumentos" {
  run bash "$BIN/race-run"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "race-run: falla si fichero no existe" {
  run bash "$BIN/race-run" "/tmp/no_existe_$$.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no encontrado"* ]]
}

# ------------------------------------------------
# mktarget
# ------------------------------------------------
@test "mktarget: falla sin argumentos" {
  run bash "$BIN/mktarget"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "mktarget: crea la estructura de directorios" {
  run bash "$BIN/mktarget" "test.com"
  [ "$status" -eq 0 ]
  [ -d "$TMP_DIR/hunting/targets/test.com/recon" ]
  [ -d "$TMP_DIR/hunting/targets/test.com/http" ]
  [ -d "$TMP_DIR/hunting/targets/test.com/fuzz" ]
  [ -d "$TMP_DIR/hunting/targets/test.com/in" ]
  [ -d "$TMP_DIR/hunting/targets/test.com/meta" ]
  [ -f "$TMP_DIR/hunting/targets/test.com/in/resolvers.txt" ]
  [ -f "$TMP_DIR/hunting/targets/test.com/notes/summary.md" ]
}

# ------------------------------------------------
# scope
# ------------------------------------------------
@test "scope: falla sin argumentos" {
  run bash "$BIN/scope"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}

@test "scope: crea estructura si subfinder no está disponible (check dep)" {
  # scope debe salir con error por dep faltante, no por otra razón
  PATH_ORIG="$PATH"
  export PATH="/usr/bin:/bin"  # excluye go/bin y herramientas
  run bash "$BIN/scope" "test.com"
  export PATH="$PATH_ORIG"
  # debe fallar por subfinder|anew faltante, no por pánico
  [ "$status" -ne 0 ]
  [[ "$output" == *"Falta"* || "$output" == *"subfinder"* || "$output" == *"anew"* ]]
}

# ------------------------------------------------
# subscan
# ------------------------------------------------
@test "subscan: falla sin argumentos" {
  run bash "$BIN/subscan"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Uso:"* ]]
}
