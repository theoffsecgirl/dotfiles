# Bug Bounty Operational Stack Setup

Guía para montar y validar el entorno completo.

## Arquitectura

```text
macOS / Linux host
├── zsh + dotfiles
├── Git y documentación
├── Claude Code
├── Caido + caido-mcp-server (opcional)
└── contenedor offsec
    ├── subfinder
    ├── httpx
    ├── katana
    ├── unfurl
    ├── ffuf
    ├── jq
    └── python3
```

## Instalación

```bash
git clone https://github.com/theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

Configura la ruta local del workspace en `~/.config/zsh/local.zsh`:

```zsh
export HUNTING_HOME="$HOME/hunting"
```

Valida:

```bash
hunt-doctor
hunt-ai doctor
```

Para aplicar solo los scripts con Stow:

```bash
cd ~/.dotfiles
stow --restow -t "$HOME" scripts
rehash
```

## Modelo operativo

### Host

Usa el host para:

- Git y dotfiles;
- notas y reportes;
- Claude Code;
- Caido;
- `hunt-ai`.

### Contenedor

Usa el contenedor para:

- enumeración;
- crawling;
- extracción de parámetros;
- fuzzing controlado;
- herramientas ofensivas reproducibles.

## Crear un target

### Single-domain

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

### Programa multi-dominio

```bash
program-init example
nvim "$HUNTING_HOME/targets/example/in/brief.txt"
program-import-brief example "$HUNTING_HOME/targets/example/in/brief.txt"

nvim "$HUNTING_HOME/targets/example/in/roots.txt"
nvim "$HUNTING_HOME/targets/example/in/scope-web.txt"
nvim "$HUNTING_HOME/targets/example/in/out-of-scope.txt"

scope-program example
webmap example
paramhunt-v2 example
```

## Workflow de IA

Los wrappers antiguos `claude-recon`, `claude-hypotheses` y `chatgpt-*` ya no forman parte del flujo. El único punto de entrada es `hunt-ai`.

### 1. Indexar localmente

```bash
hunt-ai index example
```

Genera:

```text
$HUNTING_HOME/targets/example/ai/context.json
```

El indexador resume `httpx.jsonl`, URLs candidatas, GraphQL, parámetros sensibles, scope, tecnologías y estados HTTP. No usa Claude y no envía datos fuera del equipo.

### 2. Generar prompts sin consumir Claude

```bash
hunt-ai analyze example --prompt-only
hunt-ai hypotheses example --prompt-only
hunt-ai caido example --prompt-only
hunt-ai report example --prompt-only
```

### 3. Ejecutar Claude Code

```bash
hunt-ai analyze example
hunt-ai hypotheses example
hunt-ai caido example
hunt-ai report example
```

Cada fase usa entradas distintas:

- `analyze`: `ai/context.json`;
- `hypotheses`: contexto + análisis previo cuando existe;
- `caido`: contexto + resumen del target, con reglas de solo lectura;
- `report`: findings y evidencia ya validada.

## Caido MCP

Caido debe estar escuchando localmente y Claude Code debe tener el MCP registrado como `caido`.

Comprobación:

```bash
claude mcp get caido
hunt-ai doctor
```

Reglas por defecto:

- lectura y comparación de tráfico existente;
- no Replay;
- no Automate;
- no crawlers ni scans;
- no exposición de cookies, tokens o `Authorization`;
- no peticiones nuevas sin un flujo explícito de validación.

## Artefactos principales

### Recon

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
http/urls.txt
http/api_candidates.txt
http/graphql.txt
js/files.txt
fuzz/params.txt
fuzz/sensitive_params.txt
meta/*.json
```

### IA

```text
ai/context.json
ai/analyze.prompt.md
ai/analyze.md
ai/hypotheses.prompt.md
ai/hypotheses.md
ai/caido.prompt.md
ai/caido.md
ai/report.prompt.md
ai/report.md
```

## Validación local

```bash
cd ~/.dotfiles
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats
./install.sh --dry-run
```

Prueba funcional sin tokens:

```bash
hunt-ai index example
hunt-ai analyze example --prompt-only
jq empty "$HUNTING_HOME/targets/example/ai/context.json"
wc -c "$HUNTING_HOME/targets/example/ai/"*.prompt.md
```

## Troubleshooting

### `hunt-ai: command not found`

```bash
cd ~/.dotfiles
stow --restow -t "$HOME" scripts
rehash
type -a hunt-ai
```

### Target no encontrado

```bash
echo "$HUNTING_HOME"
ls -la "$HUNTING_HOME/targets"
```

El nombre pasado a `hunt-ai` debe coincidir con una carpeta existente en `$HUNTING_HOME/targets/`.

### Git dice que no es un repositorio

Los comandos Git del proyecto deben ejecutarse desde:

```bash
cd ~/.dotfiles
```

No desde `$HUNTING_HOME/targets/<target>`.

### Claude no está disponible

`index` y `--prompt-only` siguen funcionando sin tokens ni sesión activa de Claude Code.

## Seguridad

- `~/.config/zsh/local.zsh` no se versiona;
- no se guardan tokens de Claude o Caido en el repo;
- los prompts evitan secretos y datos personales;
- el reporting no convierte hipótesis en findings;
- solo se prueban activos autorizados.
