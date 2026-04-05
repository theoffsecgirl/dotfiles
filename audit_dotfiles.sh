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
grep -RIn '^#!/bin/sh\|^#!/usr/bin/env sh' "$ROOT" || true
echo

echo "[4] Bashismos en scripts sh"
while read -r f; do
  grep -nE '\[\[|<<<|< <\(|function |mapfile|readarray|declare -A|&>' "$f" 2>/dev/null | sed "s|^|$f:|"
done < <(grep -RIl '^#!/bin/sh\|^#!/usr/bin/env sh' "$ROOT") || true
echo

echo "[5] Sintaxis bash"
find "$ROOT" -type f \( -name "*.sh" -o -path "*/bin/*" -o -path "*/.local/bin/*" \) | while read -r f; do
  if head -n1 "$f" | grep -q 'bash'; then
    bash -n "$f" || echo "[BASH-ERR] $f"
  fi
done
