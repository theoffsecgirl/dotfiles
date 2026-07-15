#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HUNTING_HOME="$TEST_HOME/hunting"
  export TARGET="example"
  BASE="$HUNTING_HOME/targets/$TARGET"
  mkdir -p "$BASE/in" "$BASE/notes" "$BASE/http" "$BASE/fuzz"
  printf 'example.com\n' > "$BASE/in/scope-web.txt"
  printf 'admin.example.com\n' > "$BASE/in/out-of-scope.txt"
  printf 'example.com\n' > "$BASE/in/roots.txt"
  printf '# Test target\n' > "$BASE/notes/summary.md"
  printf '%s\n' '{"url":"https://api.example.com/v1/users/123","host":"api.example.com","status_code":200,"title":"API","tech":["nginx"]}' > "$BASE/http/httpx.jsonl"
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/.local/bin/hunt-ai"
}

@test "hunt-ai muestra ayuda sin argumentos" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"hunt-ai index"* ]]
}

@test "hunt-ai genera contexto JSON sin Claude" {
  run bash "$SCRIPT" index "$TARGET"
  [ "$status" -eq 0 ]
  [ -f "$BASE/ai/context.json" ]
  python3 -m json.tool "$BASE/ai/context.json" >/dev/null
  grep -q 'api.example.com' "$BASE/ai/context.json"
  grep -q 'admin.example.com' "$BASE/ai/context.json"
}

@test "hunt-ai genera prompt compacto sin incluir httpx bruto" {
  python3 - <<'PY' >> "$BASE/http/httpx.jsonl"
import json
print(json.dumps({"url": "https://example.com/" + "x" * 100000, "host": "example.com", "status_code": 200}))
PY

  run bash "$SCRIPT" analyze "$TARGET" --prompt-only
  [ "$status" -eq 0 ]
  [ -f "$BASE/ai/analyze.prompt.md" ]
  grep -q 'example.com' "$BASE/ai/analyze.prompt.md"
  [ "$(wc -c < "$BASE/ai/analyze.prompt.md")" -lt 60000 ]
}

@test "hypotheses reutiliza análisis cuando existe" {
  mkdir -p "$BASE/ai"
  printf '# Prioridad observada\n' > "$BASE/ai/analyze.md"
  run bash "$SCRIPT" hypotheses "$TARGET" --prompt-only
  [ "$status" -eq 0 ]
  grep -q 'Prioridad observada' "$BASE/ai/hypotheses.prompt.md"
}

@test "hunt-ai rechaza subcomando desconocido" {
  run bash "$SCRIPT" unknown "$TARGET" --prompt-only
  [ "$status" -eq 1 ]
  [[ "$output" == *"Subcomando no soportado"* ]]
}
