<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)

**Dotfiles para bug bounty y pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇬🇧 [English version](README.md)

</div>

## Qué es esto

Un entorno de bug bounty orientado a macOS y terminal, construido alrededor de un workflow reproducible. El repositorio gestiona la configuración de shell, wrappers de hunting, instalación de tooling, estructura de targets y un flujo indexado para Claude Code.

## Instalación

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

Para simular Stow sin aplicar cambios:

```bash
./install.sh --dry-run
```

La configuración específica de cada máquina vive en `~/.config/zsh/local.zsh`, que no se versiona:

```zsh
export HUNTING_HOME="$HOME/hunting"
```

Valida el entorno:

```bash
hunt-doctor
hunt-ai doctor
```

## Workflow de bug bounty

### Target de un solo dominio

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

Los outputs principales quedan dentro de `$HUNTING_HOME/targets/<target>/`:

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/urls.txt
http/api_candidates.txt
http/graphql.txt
js/files.txt
fuzz/params.txt
fuzz/sensitive_params.txt
meta/*.json
```

## Workflow de IA indexado

`hunt-ai` es el único punto de entrada soportado para IA. Los antiguos wrappers `claude-recon`, `claude-hypotheses` y `chatgpt-*` se eliminaron en lugar de conservar capas de compatibilidad muertas.

```bash
hunt-ai index <target>
hunt-ai analyze <target> --prompt-only
hunt-ai hypotheses <target> --prompt-only
hunt-ai caido <target> --prompt-only
hunt-ai report <target> --prompt-only
```

Quita `--prompt-only` para invocar Claude Code.

El flujo está separado por fases:

```text
outputs brutos de recon
    ↓
hunt-ai index
    ↓
ai/context.json
    ↓
analyze → hypotheses → revisión en Caido → report
```

`index` es local y determinista. Resume ficheros grandes como `http/httpx.jsonl` en `ai/context.json`, de forma que Claude recibe contexto estructurado y compacto en lugar de volcados completos de recon.

Artefactos generados:

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

Reglas:

- se lee primero scope y out-of-scope;
- una hipótesis no se trata como hallazgo confirmado;
- `caido` funciona en solo lectura por defecto;
- no se muestran secretos, cookies ni cabeceras de autorización;
- `report` trabaja con evidencia validada, no con recon bruto;
- cuando falta evidencia se indica, no se inventa.

Consulta [`docs/ai-workflow.md`](docs/ai-workflow.md) para el diseño completo.

## Caido MCP

La integración opcional con Caido espera un servidor MCP local registrado como `caido` en Claude Code. `hunt-ai caido` prepara un análisis de solo lectura; no debe reenviar peticiones, ejecutar Automate, iniciar crawlers ni modificar tráfico.

Comprueba la integración con:

```bash
hunt-ai doctor
claude mcp get caido
```

## Comandos útiles

```bash
cdh        # $HUNTING_HOME
cdt        # $HUNTING_HOME/targets
bbref      # referencia interactiva de bug bounty
hunt-doctor
hunt-ai doctor
```

Valida la resolución de comandos:

```bash
type -a program-init scope-program program-import-brief scope webmap paramhunt-v2 hunt-ai
```

Todo debería resolverse a `~/.local/bin/*`.

## Tests y auditoría

```bash
cd ~/.dotfiles
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats
bash audit_dotfiles.sh ~/.dotfiles
```

## Estructura

```text
~/.dotfiles/
├── zsh/
├── scripts/
│   └── .local/
│       ├── bin/
│       ├── lib/
│       └── share/hunt-ai/
├── docs/
├── tests/
├── tmux/
├── nvim/
├── ghostty/
├── git/
├── brew/
├── tools/
├── install.sh
└── audit_dotfiles.sh
```

Gestionado con GNU Stow.

## Uso ético

Solo se deben probar sistemas para los que exista autorización explícita.

## Licencia

MIT
