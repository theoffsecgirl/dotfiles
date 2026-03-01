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

## Wordlists comunes

```bash
# Ver paths
wl-common              # dirb common.txt
wl-medium              # seclists medium

# Usar
ffuf -u https://example.com/FUZZ -w $(wl-common) -c
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

# Archivo de notas
cat ~/hunting/notes/$(date +%Y-%m-%d)-quick.md

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
venv-create                    # alias

# Activar
source venv/bin/activate
venv-activate                  # alias

# Desactivar
deactivate
venv-deactivate                # alias

# Auto-activar si existe
venv-auto
```

### Script rápido
```bash
cd ~/hunting/scripts
nvim exploit.py
```

```python
import httpx
import sys

url = sys.argv[1]
r = httpx.get(url)
print(r.status_code)
print(r.text)
```

```bash
python3 exploit.py https://example.com
```

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
note "example.com/api/users - CORS misconfigured, accepts any origin"
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

## Troubleshooting

### Contenedor no arranca
```bash
cd ~/.dotfiles/containers/debian-toolbox
docker compose logs
docker compose down
docker compose up -d
```

### Herramienta no encontrada
```bash
# Verificar PATH
echo $PATH | grep go

# Reinstalar
offsec-rebuild
```

### Dotfiles no se cargan
```bash
# Dentro del contenedor
cd /root/.dotfiles
stow -t "$HOME" zsh tmux
source ~/.zshrc
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

### Payloads
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [SecLists](https://github.com/danielmiessler/SecLists)
