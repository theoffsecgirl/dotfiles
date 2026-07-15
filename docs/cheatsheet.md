# 🔍 TheOffSecGirl — Cheatsheet

Referencia rápida de los comandos principales.

## Navegación

| Comando | Acción |
|---|---|
| `cdh` | `cd $HUNTING_HOME` |
| `cdt` | `cd $HUNTING_HOME/targets` |
| `cdn` | `cd $HUNTING_HOME/notes` |
| `cd ~/.dotfiles` | volver al repositorio Git |

## Diagnóstico

```bash
hunt-doctor
hunt-ai doctor
type -a scope webmap paramhunt-v2 hunt-ai
```

## Target single-domain

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

## Programa multi-dominio

```bash
program-init example
program-import-brief example "$HUNTING_HOME/targets/example/in/brief.txt"
scope-program example
webmap example
paramhunt-v2 example
```

Antes del recon revisa:

```text
in/roots.txt
in/scope-web.txt
in/out-of-scope.txt
```

## Hunt AI

| Comando | Descripción |
|---|---|
| `hunt-ai index target` | Resume outputs en `ai/context.json` sin usar IA |
| `hunt-ai analyze target` | Prioriza superficie y flujos |
| `hunt-ai hypotheses target` | Genera hasta cinco hipótesis justificadas |
| `hunt-ai caido target` | Analiza tráfico existente mediante Caido MCP, solo lectura |
| `hunt-ai report target` | Prepara reporte desde evidencia validada |
| `hunt-ai doctor` | Comprueba Python, jq, Claude y Caido MCP |

Generar sin consumir Claude Code:

```bash
hunt-ai analyze target --prompt-only
hunt-ai hypotheses target --prompt-only
hunt-ai caido target --prompt-only
hunt-ai report target --prompt-only
```

Validar el contexto:

```bash
jq empty "$HUNTING_HOME/targets/target/ai/context.json"
wc -c "$HUNTING_HOME/targets/target/ai/"*.prompt.md
```

## Caido MCP

```bash
claude mcp get caido
hunt-ai doctor
```

Reglas: lectura por defecto, sin Replay, Automate, crawlers, scans ni exposición de secretos.

## Scripts principales

| Comando | Uso |
|---|---|
| `program-init` | crea workspace multi-dominio |
| `program-import-brief` | importa y estructura el brief |
| `scope-program` | recon multi-dominio |
| `mktarget` | crea target single-domain |
| `scope` | wrapper estable de recon inicial |
| `webmap` | wrapper estable de crawling |
| `paramhunt-v2` | extracción de parámetros |
| `subscan` | vista rápida de hosts HTTP |
| `fuzzdirs` | fuzzing manual de directorios |
| `hunt-ai` | workflow indexado de IA |
| `hunt-doctor` | diagnóstico del entorno |

Los comandos eliminados `claude-recon`, `claude-hypotheses` y `chatgpt-*` no deben reaparecer.

## Tests

```bash
cd ~/.dotfiles
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats
./install.sh --dry-run
```

## Stow

```bash
cd ~/.dotfiles
stow --restow -t "$HOME" scripts
rehash
```

## HTTP

| Alias | Equivalente |
|---|---|
| `h` | `httpx -silent` |
| `hh` | `httpx -silent -tech-detect -status-code` |
| `hhh` | `httpx -silent -tech-detect -status-code -title -web-server` |
| `ch` | `curl -sI` |
| `f` | `ffuf -c -mc all -fc 404` |

## Regla operativa

```text
contenedor = tooling ofensivo
host       = Git, notas, Claude Code, Caido y hunt-ai
```
