# 🔍 theoffsecgirl — Cheatsheet

Referencia rápida de todos los comandos disponibles tras instalar los dotfiles.

---

## 📁 Navegación workspace

| Alias | Acción |
|-------|--------|
| `cdh` | `cd ~/hunting` |
| `cdt` | `cd ~/hunting/targets` |
| `cdn` | `cd ~/hunting/notes` |
| `cds` | `cd ~/hunting/scripts` |

---

## 🎯 Flujo de trabajo (orden recomendado)

```bash
# 1. Crear estructura del target
mktarget example.com

# 2. Recon inicial: subdominios + hosts vivos
scope example.com

# 3. Crawl de URLs y JS
webmap example.com

# 4. Extraer parámetros únicos
paramhunt example.com

# 5. Fuzz de directorios
fuzzdirs https://example.com

# 6. Tabla de endpoints vivos
subscan example.com

# 7. Abrir sesión tmux de 4 panes
tmux-recon recon-example ~/hunting/targets/example.com
```

---

## 🔧 Scripts en `~/.local/bin/`

| Comando | Uso | Descripción |
|---------|-----|-------------|
| `mktarget` | `mktarget domain.com` | Crea estructura completa del target |
| `scope` | `scope domain.com` | Subdominios + hosts vivos |
| `webmap` | `webmap domain.com` | Crawl katana → urls.txt + js/files.txt |
| `paramhunt` | `paramhunt domain.com` | Extrae parámetros únicos de urls.txt |
| `fuzzdirs` | `fuzzdirs https://url` | Fuzz de directorios con ffuf |
| `subscan` | `subscan domain.com` | Tabla httpx con status, IP, título |
| `jwt-decode` | `jwt-decode <token>` | Decodifica header+payload de JWT |
| `race-run` | `race-run req.txt [n]` | Race condition: N requests en paralelo |
| `idor-hints` | `idor-hints` | Checklist IDOR en terminal |
| `offsec-up` | `offsec-up` | Arranca contenedor offsec-toolbox |
| `offsec-shell` | `offsec-shell` | Shell dentro del contenedor |
| `tmux-recon` | `tmux-recon [sesión] [dir]` | 4 panes: control, logs, nvim, runner |
| `tmux-sessionizer` | `C-a f` o directamente | Switch de proyecto con fzf |

---

## 🐳 Contenedor offsec-toolbox

```bash
# Arrancar
offsec-up          # o: offsec-restart / offsec-rebuild

# Conectar
offsec-shell       # o: docker exec -it offsec-toolbox zsh

# Actualizar versiones de herramientas
cd ~/.dotfiles/containers/debian-toolbox
docker compose build --build-arg HTTPX_VERSION=1.6.11
```

---

## 🌐 HTTP shortcuts

| Alias | Comando equivalente |
|-------|--------------------|
| `h` | `httpx -silent` |
| `hh` | `httpx -silent -tech-detect -status-code` |
| `hhh` | `httpx -silent -tech-detect -status-code -title -web-server` |
| `ch` | `curl -sI` |
| `f` | `ffuf -c -mc all -fc 404` |

---

## ⌨️ tmux (prefix: `C-a`)

| Binding | Acción |
|---------|--------|
| `C-a \|` | Split horizontal |
| `C-a -` | Split vertical |
| `C-a h/j/k/l` | Navegar panes |
| `C-a f` | tmux-sessionizer (fzf) |
| `C-a g` | Popup terminal |
| `C-a C-n` | Popup notas de hoy |
| `C-a H` | Split a ~/hunting |
| `C-a r` | Reload config |
| `C-a b` | Toggle status bar |

---

## 📝 Neovim (leader: `Space`)

| Binding | Acción |
|---------|--------|
| `<leader>ff` | Buscar fichero (Telescope) |
| `<leader>fg` | Grep en proyecto |
| `<leader>n` | Notas de hoy |
| `<leader>t` | Terminal flotante |
| `<leader>mp` | Markdown preview |
| `<leader>w/q` | Guardar / Salir |
| `-` | Oil (explorador) |
| `gd / gr / K` | LSP: definición, refs, hover |
| `<leader>f` | Format LSP |
| `[d / ]d` | Diagnóstico prev/next |

---

## 🔑 Funciones zsh útiles

```bash
subenum domain.com       # subfinder + crt.sh deduplicados
probe urls.txt           # httpx sobre lista de URLs
note 'hallazgo XSS'      # añade nota con timestamp
notes                    # últimas 20 notas de hoy
venv-auto                # activa venv o .venv automáticamente
mkproject domain.com     # proyecto con dns-pipeline completo
```

---

## 🐧 Exegol

```bash
ex nmap -sV target       # ejecuta en contenedor Exegol (filtra banner)
exv nmap -sV target      # modo debug (sin filtrar)
```
