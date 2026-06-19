#!/usr/bin/env bash
# shellcheck shell=bash

log_info() { printf '[*] %s\n' "$*"; }
log_ok() { printf '[+] %s\n' "$*"; }
log_warn() { printf '[!] %s\n' "$*" >&2; }
log_err() { printf '[x] %s\n' "$*" >&2; }

die() {
  log_err "$*"
  exit 1
}

need_cmd() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Falta dependencia: $cmd"
  done
}

ensure_dir() {
  mkdir -p "$@"
}

count_lines_safe() {
  local file="$1"
  [[ -f "$file" ]] || {
    printf '0\n'
    return 0
  }
  wc -l < "$file" | tr -d ' '
}

first_available_cmd() {
  local cmd
  for cmd in "$@"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '%s\n' "$cmd"
      return 0
    fi
  done
  return 1
}

# Rechaza un argumento que parezca una flag (empieza por '-') cuando se espera un target/programa.
# Llamar DESPUÉS de haber manejado -h/--help.
_reject_flag_as_target() {
  local val="$1"
  [[ "$val" == -* ]] && {
    printf '[!] Argumento inválido: '"'"'%s'"'"' parece una flag, no un target/programa\n' "$val" >&2
    exit 1
  }
}

# Envuelve una llamada a una tool externa e imprime un mensaje claro si falla.
# Apta para uso como primer comando de una tubería.
run_or_explain() {
  local tool="$1"; shift
  local rc=0
  "$tool" "$@" || rc=$?
  if [[ $rc -ne 0 ]]; then
    printf '[!] Falló: %s %s\n' "$tool" "$*" >&2
    printf '[!] Exit code: %d — revisa flags vs '"'"'%s -h'"'"' o '"'"'%s -version'"'"'\n' \
      "$rc" "$tool" "$tool" >&2
    return $rc
  fi
}
