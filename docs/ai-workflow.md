# AI Workflow for Bug Bounty

`hunt-ai` convierte los outputs locales del target en contexto compacto antes de invocar Claude Code. El objetivo es evitar prompts enormes, no repetir recon y separar claramente análisis, hipótesis, tráfico y reporting.

## Flujo

```text
scope / scope-program
        ↓
webmap
        ↓
paramhunt-v2
        ↓
hunt-ai index
        ↓
ai/context.json
        ↓
hunt-ai analyze
        ↓
hunt-ai hypotheses
        ↓
hunt-ai caido
        ↓
validación manual controlada
        ↓
hunt-ai report
```

## Comandos

```bash
hunt-ai index <target>
hunt-ai analyze <target> [--prompt-only]
hunt-ai hypotheses <target> [--prompt-only]
hunt-ai caido <target> [--prompt-only]
hunt-ai report <target> [--prompt-only]
hunt-ai doctor
```

### `index`

Procesa localmente los artefactos existentes y genera:

```text
$HUNTING_HOME/targets/<target>/ai/context.json
```

El índice resume hosts, estados, tecnologías, endpoints interesantes, GraphQL, parámetros sensibles y scope. No usa Claude ni envía datos fuera del equipo.

### `analyze`

Lee `ai/context.json` y prioriza superficie, flujos sensibles y huecos de información. No declara vulnerabilidades.

### `hypotheses`

Lee el contexto y, cuando existe, `ai/analyze.md`. Devuelve un máximo de cinco hipótesis justificadas y comprobables.

### `caido`

Prepara una sesión para usar el MCP `caido` en modo de solo lectura. Puede listar, filtrar, leer y comparar tráfico ya capturado. No debe reenviar peticiones, ejecutar Replay, Automate, crawlers, workflows, tamper ni intercept.

### `report`

Trabaja únicamente con evidencia ya validada desde `notes/findings.md`, resultados previos y notas de Caido. Si falta reproducción o impacto demostrado, debe marcar el reporte como no listo.

### `--prompt-only`

Genera el prompt localmente sin invocar Claude Code:

```bash
hunt-ai analyze doximity --prompt-only
```

Los prompts se guardan en:

```text
$HUNTING_HOME/targets/<target>/ai/*.prompt.md
```

## Principios

- Scope y exclusiones se leen antes de analizar.
- Los JSONL grandes no se copian directamente al prompt.
- Una hipótesis no es una vulnerabilidad confirmada.
- Claude no repite recon ya disponible.
- Caido es solo lectura por defecto.
- Cookies, tokens, cabeceras `Authorization`, secretos y datos personales no deben mostrarse ni persistirse.
- Las pruebas activas requieren revisión humana, bajo volumen y una modificación explícita.

## Diagnóstico

```bash
hunt-ai doctor
```

Comprueba `python3`, `jq`, Claude Code, `caido-mcp-server` y el registro MCP `caido` cuando Claude está disponible.

## Validación local sin tokens

```bash
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats

hunt-ai index doximity
hunt-ai analyze doximity --prompt-only
hunt-ai hypotheses doximity --prompt-only
hunt-ai caido doximity --prompt-only
hunt-ai report doximity --prompt-only

wc -c "$HUNTING_HOME/targets/doximity/ai/"*.prompt.md
```
