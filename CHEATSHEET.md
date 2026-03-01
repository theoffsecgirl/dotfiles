# Bug Bounty Cheatsheet

Comandos y workflows que uso a diario.

## Entorno

### Arrancar/Parar
```bash
# Desde macOS
offsec-up              # arrancar contenedor
offsec                 # entrar al shell
offsec-restart         # reiniciar
offsec-rebuild         # rebuild completo

# Desde Raycast
Cmd+Space → "Start Offsec Toolbox"
Cmd+Space → "Offsec Shell"
```

### Navegación
```bash
cdh                    # cd ~/hunting
cdt                    # cd ~/hunting/targets
cdn                    # cd ~/hunting/notes
cds                    # cd ~/hunting/scripts
```

## Ghostty Terminal

### Tabs
```
Cmd+T                  # nueva tab
Cmd+W                  # cerrar tab
Cmd+Shift+[/]          # tab anterior/siguiente
Cmd+1..5               # ir a tab específica
```

### Splits
```
Cmd+D                  # split vertical (derecha)
Cmd+Shift+D            # split horizontal (abajo)
Cmd+H/J/K/L            # navegar splits (vim-style)
Cmd+Ctrl+H/J/K/L       # resize splits
Cmd+Shift+W            # cerrar split
```

### Útiles
```
Cmd+C/V                # copiar/pegar
Cmd++/-/0              # aumentar/reducir/reset font
Cmd+F                  # fullscreen
Cmd+Shift+H            # nueva tab en ~/hunting
Cmd+Shift+N            # nueva tab en ~/hunting/notes
Cmd+Shift+R            # reload config
```

## Tmux

### Básicos (prefix = Ctrl+a)
```
Ctrl+a |               # split vertical
Ctrl+a -               # split horizontal
Ctrl+a h/j/k/l         # navegar panes (vim)
Ctrl+a H/J/K/L         # resize panes
Ctrl+a c               # nueva ventana
Ctrl+a x               # matar pane sin confirmación
Ctrl+a d               # detach (salir)
```

### Sessionizer
```
Ctrl+a f               # buscar y cambiar a proyecto (fzf)
```

### Popups
```
Ctrl+a g               # terminal popup flotante
Ctrl+a Ctrl+n          # popup con notas de hoy
```

### Hunting shortcuts
```
Ctrl+a H               # split en ~/hunting
Ctrl+a T               # split en ~/hunting/targets
Ctrl+a N               # split con nvim en notes
```

### Windows
```
Ctrl+a 0..9            # ir a ventana
Ctrl+a </>             # mover ventana izq/der
Ctrl+a n/p             # siguiente/anterior ventana
```

### Sessions (con resurrect)
```
Ctrl+a Ctrl+s          # guardar sesión
Ctrl+a Ctrl+r          # restaurar sesión
# Auto-save cada 15 min activo
```

### Copy mode
```
Ctrl+a [               # entrar copy mode
Space                  # comenzar selección
y                      # copiar (va a clipboard)
q                      # salir
```

### Útiles
```
Ctrl+a r               # reload config
Ctrl+a b               # toggle status bar
Ctrl+a z               # zoom pane (fullscreen temporal)
```

## Neovim

### Dashboard (al abrir)
```
h                      # Hunting workspace
n                      # Notas de hoy
f                      # Buscar archivo
g                      # Buscar texto
d                      # Dotfiles
c                      # Cheatsheet
r                      # Archivos recientes
v                      # Config nvim
q                      # Salir
```

### Básicos
```
Space                  # leader key
:w  o  Space+w         # guardar
:q  o  Space+q         # salir
:wq                    # guardar y salir
:q!                    # salir sin guardar
```

### Navegación archivos
```
-                      # abrir directorio actual (oil.nvim)
Space+ff               # buscar archivos (fuzzy)
Space+fg               # buscar en contenido (grep)
Space+fb               # ver buffers abiertos
Space+n                # abrir notas de hoy
```

### Terminal integrado
```
Space+t                # toggle terminal flotante
Ctrl+x                 # salir de insert mode en terminal
```

### LSP (autocompletado y navegación)
```
gd                     # ir a definición
gr                     # ver referencias
K                      # documentación hover
Space+rn               # renombrar símbolo
Space+ca               # code actions
Space+f                # formatear archivo
[d / ]d                # diagnóstico anterior/siguiente
Space+e                # mostrar error en float
```

### Git
```
]c / [c                # siguiente/anterior cambio (hunk)
Space+hp               # preview cambio
Space+hs               # stage cambio
Space+hr               # reset cambio
Space+hb               # blame de línea
```

### Markdown
```
Space+mp               # preview markdown
```

### Búsqueda avanzada
```
:RG texto              # buscar texto en proyecto (ripgrep)
Space+ss               # símbolos en archivo
Space+sS               # símbolos en workspace
```

### Snippets (escribe + Tab)

#### Python
```
req        → import requests + GET básico
reqh       → requests con headers custom
post       → POST JSON
httpx      → httpx básico
httpxa     → httpx async
xss        → XSS fuzzer con payloads
sqli       → SQLi tester
ssrf       → SSRF tester
argp       → argparse template
```

#### Bash
```
curl       → curl GET con headers
curlp      → curl POST JSON
curlc      → curl con cookie
http       → httpie GET
httpp      → httpie POST
ffuf       → ffuf directory fuzzing
ffufp      → ffuf parameter fuzzing
subenum    → subdomain enum pipeline
recon      → one-liner recon completo
```

#### Payloads (cualquier archivo)
```
xss1       → <script>alert(1)</script>
xss2       → '><script>alert(1)</script>
xss3       → "<script>alert(1)</script>
xssimg     → <img src=x onerror=alert(1)>
sql1       → ' OR 1=1--
sql2       → ' OR '1'='1
sql3       → admin'--
lfi        → ../../../etc/passwd
lfi2       → ....//....//....//etc/passwd
ssrf1      → http://169.254.169.254/latest/meta-data/
ssrf2      → http://localhost:80
jwt        → decode JWT one-liner
```

### Ejecutar comandos HTTP
```
Space+xh               # ejecutar línea con curl/http bajo cursor
```

## Recon

### Subdominios
```bash
# Enum básico (crt.sh)
subenum example.com

# Guardar resultado
subenum example.com > subs.txt

# Con otras tools (dentro del contenedor)
subfinder -d example.com -silent
assetfinder --subs-only example.com
```

### Probing
```bash
# Probar lista de URLs
probe urls.txt

# httpx básico
cat urls.txt | httpx -silent

# Con tech detect
cat urls.txt | httpx -silent -tech-detect -status-code

# Full info
cat urls.txt | httpx -silent -tech-detect -status-code -title -web-server

# Aliases rápidos
cat urls.txt | h       # httpx silent
cat urls.txt | hh      # con tech detect
cat urls.txt | hhh     # full info
```

### Screenshots
```bash
# Con httpx
cat urls.txt | httpx -screenshot -silent
```

## Fuzzing

### Directorios
```bash
# Básico
ffuf -u https://example.com/FUZZ -w /usr/share/wordlists/common.txt -c -mc all -fc 404

# Alias
f -u https://example.com/FUZZ -w wordlist.txt

# Con extensiones
ffuf -u https://example.com/FUZZ -w wordlist.txt -e .php,.html,.js -c

# Recursivo
ffuf -u https://example.com/FUZZ -w wordlist.txt -recursion -c
```

### Parámetros
```bash
# GET params
ffuf -u 'https://example.com/api?FUZZ=test' -w params.txt -c

# POST data
ffuf -u https://example.com/api -X POST -d 'FUZZ=test' -w params.txt -c
```

### Virtualhost
```bash
ffuf -u https://example.com -H 'Host: FUZZ.example.com' -w subdomains.txt -c
```

## HTTP Testing

### curl
```bash
# Headers
curl -I https://example.com
ch https://example.com              # alias

# Con cookie
curl https://example.com -H 'Cookie: session=xxx'

# POST JSON
curl -X POST https://example.com/api \
  -H 'Content-Type: application/json' \
  -d '{"key":"value"}'

# Proxy (Burp)
curl https://example.com -x http://127.0.0.1:8080 -k
```

### httpie
```bash
# GET
http GET https://example.com
hget https://example.com                # alias

# POST JSON
http POST https://example.com/api key=value
hpost https://example.com/api key=value  # alias

# Headers custom
http GET https://example.com Authorization:'Bearer token'
```

### httpx
```bash
# Tech stack
echo example.com | httpx -tech-detect -silent

# Status codes
cat urls.txt | httpx -status-code -silent

# Response size
cat urls.txt | httpx -content-length -silent

# Match response
cat urls.txt | httpx -match-string 'admin' -silent

# Headers custom
cat urls.txt | httpx -H 'X-Custom: value' -silent
```

## JSON

### Parsing
```bash
# Pretty print
curl https://api.example.com | jq .
curl https://api.example.com | jq-pretty  # alias

# Extraer keys
curl https://api.example.com | jq keys
curl https://api.example.com | jq-keys     # alias

# Filtrar
curl https://api.example.com | jq '.data[] | .id'

# Buscar valores
curl https://api.example.com | jq '.[] | select(.role=="admin")'
```

## Notas

### Sistema de notas rápidas
```bash
# Añadir nota
note "found XSS in /search?q="

# Ver notas de hoy
notes

# Desde nvim (dashboard)
n                      # abre notas de hoy

# Desde tmux popup
Ctrl+a Ctrl+n          # popup con notas

# Notas por target
cd ~/hunting/targets/example.com
nvim notes.md
```

## Python

### Venv
```bash
# Crear
cd ~/hunting/scripts/proyecto
python3 -m venv venv

# Activar
source venv/bin/activate

# Desactivar
deactivate
```

### Script rápido con snippet
En nvim: `req` + Tab

## Workflows

### Recon completo de dominio
```bash
cd ~/hunting/targets
mkdir example.com && cd example.com
mkdir recon vulns

# Subdominios
subenum example.com | tee recon/subs.txt

# Probing
cat recon/subs.txt | httpx -silent -tech-detect -status-code | tee recon/alive.txt

# Screenshots
cat recon/alive.txt | httpx -screenshot -silent

# Notas
note "example.com - found 45 subdomains, 12 alive"
```

### Testing endpoint específico
```bash
cd ~/hunting/targets/example.com

# Request base
curl https://example.com/api/users -v | tee vulns/users-response.txt

# Headers interesantes
curl -I https://example.com/api/users | grep -i 'cors\|access-control'

# Fuzzing params
ffuf -u 'https://example.com/api/users?FUZZ=1' -w params.txt -c | tee vulns/params-fuzz.txt

# Notas
note "example.com/api/users - CORS misconfigured"
```

### Workflow con tmux + nvim
```bash
# Abrir proyecto con sessionizer
Ctrl+a f
# Seleccionar example.com

# Split para testing
Ctrl+a |

# Popup para notas rápidas
Ctrl+a Ctrl+n

# Terminal flotante para comandos
Space+t  # dentro de nvim
```

### Organizar target
```bash
~/hunting/targets/example.com/
├── recon/
│   ├── subs.txt
│   ├── alive.txt
│   └── screenshots/
├── vulns/
│   ├── xss-search.txt
│   └── idor-api.txt
└── notes.md
```

## Tips

### Combinar herramientas
```bash
# Subdominios → probing → fuzzing
subenum example.com | httpx -silent | ffuf -u FUZZ/admin -w -

# URLs de archivo → filtrar 200 → guardar
cat urls.txt | httpx -mc 200 -silent > alive-200.txt
```

### Grep útil
```bash
# Buscar en responses
grep -i 'admin\|secret\|key\|token' response.txt

# IPs en archivos
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' file.txt

# Emails
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt
```

### Proxy todo por Burp
```bash
# Variables de entorno
export HTTP_PROXY=http://127.0.0.1:8080
export HTTPS_PROXY=http://127.0.0.1:8080

# Usar
curl https://example.com -k
httpx -proxy http://127.0.0.1:8080
```

### Ghostty + Tmux combo
```
# Split en Ghostty para tener múltiples proyectos
Cmd+D              # split ghostty
# En cada split, tmux con proyecto diferente
tmux attach
```

## Troubleshooting

### Contenedor no arranca
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose logs
docker compose down
docker compose up -d
```

### Tmux plugins no instalados
```bash
# Instalar TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Dentro de tmux
Ctrl+a I  # (I mayúscula) instala plugins
```

### Ghostty font no se ve
```bash
# Instalar Nerd Font
brew install font-jetbrains-mono-nerd-font

# O cambiar en config a:
font-family = "SF Mono"
```

### Nvim snippets no funcionan
```bash
cd ~/.dotfiles
git pull
stow -t "$HOME" nvim

# Dentro de nvim
:Lazy sync
```

## Recursos

### Wordlists
- `/usr/share/wordlists/dirb/common.txt`
- `/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt`
- `/usr/share/seclists/Discovery/Web-Content/raft-large-words.txt`

### Docs oficiales
- [httpx](https://github.com/projectdiscovery/httpx)
- [ffuf](https://github.com/ffuf/ffuf)
- [jq manual](https://jqlang.github.io/jq/manual/)
- [Neovim](https://neovim.io/doc/)
- [Ghostty](https://ghostty.org/docs)
- [Tmux](https://github.com/tmux/tmux/wiki)

### Payloads
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [SecLists](https://github.com/danielmiessler/SecLists)

## Atajos de teclado resumen

### Ghostty (más usados)
```
Cmd+T       → nueva tab
Cmd+D       → split vertical
Cmd+H/J/K/L → navegar splits
Cmd+Shift+H → tab en ~/hunting
```

### Tmux (más usados)
```
Ctrl+a |    → split vertical
Ctrl+a f    → sessionizer
Ctrl+a g    → popup terminal
Ctrl+a Ctrl+n → popup notas
Ctrl+a H/T/N  → hunting shortcuts
```

### Nvim (más usados)
```
Space+ff    → buscar archivo
Space+fg    → buscar texto
Space+n     → notas de hoy
Space+t     → terminal
-           → file explorer
gd          → ir a definición
```

### Terminal
```
cdh         → ~/hunting
offsec      → entrar contenedor
h           → httpx silent
f           → ffuf
note        → nota rápida
```
