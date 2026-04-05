# 🔍 theoffsecgirl — Cheatsheet

Referencia rápida de los comandos principales del entorno.

---

## Navegación workspace

| Alias | Acción |
|-------|--------|
| `cdh` | `cd ~/hunting` |
| `cdt` | `cd ~/hunting/targets` |
| `cdn` | `cd ~/hunting/notes` |
| `cds` | `cd ~/hunting/scripts` |

---

## Bootstrap y validación

```bash
offsec-bootstrap
hunt-doctor
```

- `offsec-bootstrap` → enlaza scripts de `~/.dotfiles/scripts/.local/bin/` a `~/.local/bin/`
- `hunt-doctor` → valida entorno, scripts y tooling

---

## Modelo operativo

### Host
- Git
- dotfiles
- Claude Code
- edición y documentación

### Contenedor
- `subfinder`
- `httpx`
- `katana`
- `unfurl`
- `ffuf`
- `jq`
- `python3`
- `scope-v2`
- `webmap-v2`
- `paramhunt-v2`

---

## Flujo recomendado

### Contenedor
```bash
mktarget example.com
scope-v2 example.com
webmap-v2 example.com
paramhunt-v2 example.com
```

### Host
```bash
claude-recon example.com
claude-hypotheses example.com
```

---

## Scripts en `~/.local/bin/`

| Comando | Uso | Descripción |
|---------|-----|-------------|
| `mktarget` | `mktarget domain.com` | Crea estructura completa del target |
| `scope` | `scope domain.com` | Recon básico legacy |
| `webmap` | `webmap domain.com` | Crawl básico legacy |
| `paramhunt` | `paramhunt domain.com` | Extracción básica legacy |
| `scope-v2` | `scope-v2 domain.com` | Subdominios + hosts vivos + `httpx.jsonl` |
| `webmap-v2` | `webmap-v2 domain.com` | Crawl + separación de URLs, JS, API y GraphQL |
| `paramhunt-v2` | `paramhunt-v2 domain.com` | Params por URL, sensibles y JSONL por host |
| `claude-recon` | `claude-recon domain.com` | Análisis IA de recon |
| `claude-hypotheses` | `claude-hypotheses domain.com` | Hipótesis estructuradas de ataque |
| `fuzzdirs` | `fuzzdirs https://url` | Fuzz de directorios con ffuf |
| `subscan` | `subscan domain.com` | Tabla rápida httpx con status, IP y título |
| `offsec-up` | `offsec-up` | Arranca contenedor offsec-toolbox |
| `offsec-shell` | `offsec-shell` | Shell dentro del contenedor |
| `offsec-bootstrap` | `offsec-bootstrap` | Enlaza scripts de forma idempotente |
| `hunt-doctor` | `hunt-doctor` | Valida entorno y tooling |

---

## Contenedor offsec-toolbox

```bash
offsec-up
offsec-shell
offsec-bootstrap
hunt-doctor
```

Actualizar tooling:

```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose build --build-arg HTTPX_VERSION=1.6.11
```

---

## Shortcuts HTTP

| Alias | Comando equivalente |
|-------|--------------------|
| `h` | `httpx -silent` |
| `hh` | `httpx -silent -tech-detect -status-code` |
| `hhh` | `httpx -silent -tech-detect -status-code -title -web-server` |
| `ch` | `curl -sI` |
| `f` | `ffuf -c -mc all -fc 404` |

---

## Regla clave

- Contenedor = tooling ofensivo
- Host = Claude / Git / docs
