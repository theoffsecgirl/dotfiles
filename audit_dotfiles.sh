#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

echo "[1] Conflictos de merge"
grep -RInE '<<<<<<<|=======|>>>>>>>' "$ROOT" || true
echo

echo "[2] CRLF"
find "$ROOT" -type f \( -name "*.sh" -o -path "*/bin/*" -o -path "*/.local/bin/*" \) -print0 | \
xargs -0 file 2>/dev/null | grep CRLF || true
echo

echo "[3] Scripts sh"
grep -RIEn '^#!/bin/sh|^#!/usr/bin/env sh' "$ROOT" || true
echo

echo "[4] Bashismos en scripts sh"
while read -r f; do
  grep -nE '\[\[|<<<|< <\(|function |mapfile|readarray|declare -A|&>' "$f" 2>/dev/null | sed "s|^|$f:|"
done < <(grep -RIEl '^#!/bin/sh|^#!/usr/bin/env sh' "$ROOT") || true
echo

echo "[5] Sintaxis bash"
find "$ROOT" -type f \( -name "*.sh" -o -name "*.zsh" -o -path "*/bin/*" -o -path "*/.local/bin/*" \) | while read -r f; do
  if head -n1 "$f" | grep -q 'bash'; then
    bash -n "$f" || echo "[BASH-ERR] $f"
  fi
done
echo

echo "[6] Sintaxis zsh"
if command -v zsh >/dev/null 2>&1; then
  find "$ROOT" -type f -name "*.zsh" | while read -r f; do
    zsh -n "$f" || echo "[ZSH-ERR] $f"
  done
else
  echo "zsh no disponible, omitido"
fi
echo

echo "[7] Shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
  find "$ROOT" -type f ! -path '*/.git/*' ! -path '*/vendor/*' | while IFS= read -r f; do
    shebang=$(head -1 "$f" 2>/dev/null)
    case "$shebang" in
      '#!/bin/bash'*|'#!/usr/bin/env bash'*|'#!/bin/zsh'*|'#!/usr/bin/env zsh'*)
        shellcheck --severity=warning --shell=bash "$f" ;;
      '#!/bin/sh'*|'#!/usr/bin/env sh'*)
        shellcheck --severity=warning --shell=sh "$f" ;;
    esac
  done
else
  echo "shellcheck no instalado — 'brew install shellcheck'"
fi

echo
echo "[8] Funciones zsh duplicadas entre ficheros cargados desde load.zsh"
if command -v zsh >/dev/null 2>&1; then
  _ZSH_FILES=(
    "$ROOT/vendor/shell-utils/zsh/aliases-builtin.zsh"
    "$ROOT/vendor/shell-utils/zsh/aliases-bugbounty.zsh"
    "$ROOT/vendor/shell-utils/zsh/aliases-mac-containers.zsh"
    "$ROOT/vendor/shell-utils/zsh/functions-bugbounty.zsh"
    "$ROOT/vendor/shell-utils/zsh/wrapper-exegol.zsh"
    "$ROOT/zsh/.config/zsh/aliases-general.zsh"
    "$ROOT/zsh/.config/zsh/bug-bounty.zsh"
  )
  declare -A _FN_SEEN
  _dups=0
  for _f in "${_ZSH_FILES[@]}"; do
    [[ -f "$_f" ]] || continue
    while IFS= read -r _fn; do
      [[ -z "$_fn" ]] && continue
      if [[ -n "${_FN_SEEN[$_fn]:-}" ]]; then
        echo "[DUPLICADO] '${_fn}' definida en:"
        echo "            ${_FN_SEEN[$_fn]}"
        echo "            $_f"
        _dups=$((_dups + 1))
      else
        _FN_SEEN[$_fn]="$_f"
      fi
    done < <(grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\(\)' "$_f" \
               | sed -E 's/[[:space:]]*\(\).*//' | sed -E 's/^[[:space:]]*//')
  done
  unset _FN_SEEN _f _fn
  [[ $_dups -eq 0 ]] && echo "(ninguna duplicada)" || echo "[!] $_dups función(es) duplicadas"
  unset _dups _ZSH_FILES
else
  echo "zsh no disponible, omitido"
fi
