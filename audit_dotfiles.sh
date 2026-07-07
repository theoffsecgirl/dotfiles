#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

echo "[1] Conflictos de merge"
grep -RInE '^<{7}( |$)|^={7}$|^>{7}( |$)' --exclude-dir='.git' "$ROOT" || true
echo

echo "[2] CRLF"
find "$ROOT" -type f \( -name "*.sh" -o -path "*/bin/*" -o -path "*/.local/bin/*" \) -print0 | \
xargs -0 file 2>/dev/null | grep CRLF || true
echo

echo "[3] Scripts sh"
grep -RIEn --exclude-dir='.git' '^#!/bin/sh|^#!/usr/bin/env sh' "$ROOT" || true
echo

echo "[4] Bashismos en scripts sh"
while read -r f; do
  grep -nE '\[\[|<<<|< <\(|function |mapfile|readarray|declare -A|&>' "$f" 2>/dev/null | sed "s|^|$f:|"
done < <(grep -RIEl --exclude-dir='.git' '^#!/bin/sh|^#!/usr/bin/env sh' "$ROOT") || true
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
  {
    for _f in "${_ZSH_FILES[@]}"; do
      [[ -f "$_f" ]] || continue
      while IFS= read -r _fn; do
        [[ -z "$_fn" ]] && continue
        printf '%s\t%s\n' "$_fn" "$_f"
      done < <(grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*\(\)' "$_f" \
                 | sed -E 's/[[:space:]]*\(\).*//' | sed -E 's/^[[:space:]]*//')
    done
  } | awk -F '\t' '
    seen[$1] {
      print "[DUPLICADO] '\''" $1 "'\'' definida en:"
      print "            " seen[$1]
      print "            " $2
      dups++
      next
    }
    {
      seen[$1] = $2
    }
    END {
      if (dups == 0) {
        print "(ninguna duplicada)"
      } else {
        printf "[!] %d función(es) duplicadas\n", dups
      }
    }
  '
  unset _ZSH_FILES _f _fn
else
  echo "zsh no disponible, omitido"
fi
