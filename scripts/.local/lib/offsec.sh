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
