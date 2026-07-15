#!/usr/bin/env bats

setup() {
  export TEST_HOME="$BATS_TEST_TMPDIR/home"
  export HUNTING_HOME="$TEST_HOME/hunting"
  export TARGET="example"
  mkdir -p "$HUNTING_HOME/targets/$TARGET/in" "$HUNTING_HOME/targets/$TARGET/notes"
  printf 'example.com\n' > "$HUNTING_HOME/targets/$TARGET/in/scope-web.txt"
  printf 'admin.example.com\n' > "$HUNTING_HOME/targets/$TARGET/in/out-of-scope.txt"
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/.local/bin/hunt-ai"
}

@test "hunt-ai muestra ayuda sin argumentos" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"hunt-ai analyze"* ]]
}

@test "hunt-ai genera prompt sin Claude" {
  run bash "$SCRIPT" analyze "$TARGET" --prompt-only
  [ "$status" -eq 0 ]
  [ -f "$HUNTING_HOME/targets/$TARGET/ai/analyze.prompt.md" ]
  grep -q "example.com" "$HUNTING_HOME/targets/$TARGET/ai/analyze.prompt.md"
  grep -q "admin.example.com" "$HUNTING_HOME/targets/$TARGET/ai/analyze.prompt.md"
}

@test "hunt-ai rechaza subcomando desconocido" {
  run bash "$SCRIPT" unknown "$TARGET" --prompt-only
  [ "$status" -eq 1 ]
  [[ "$output" == *"Subcomando no soportado"* ]]
}
