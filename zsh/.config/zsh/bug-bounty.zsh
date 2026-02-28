# Bug Bounty aliases y funciones
# Se carga automáticamente si usas la estructura modular de zsh

# ==========================================
# Navegación rápida workspace
# ==========================================
alias cdh='cd ~/hunting'
alias cdt='cd ~/hunting/targets'
alias cdn='cd ~/hunting/notes'
alias cds='cd ~/hunting/scripts'

# ==========================================
# Contenedores
# ==========================================
alias offsec='docker exec -it offsec-toolbox zsh'
alias offsec-restart='cd ~/.dotfiles/containers/debian-toolbox && docker compose restart'
alias offsec-rebuild='cd ~/.dotfiles/containers/debian-toolbox && docker compose down && docker compose build --no-cache && docker compose up -d'

# ==========================================
# HTTP shortcuts
# ==========================================
alias h='httpx -silent'
alias hh='httpx -silent -tech-detect -status-code'
alias hhh='httpx -silent -tech-detect -status-code -title -web-server'

# curl con headers visibles
alias ch='curl -sI'

# httpie shortcuts
alias hget='http GET'
alias hpost='http POST'

# ==========================================
# Fuzzing
# ==========================================
alias f='ffuf -c -mc all -fc 404'

# Wordlists comunes (ajusta rutas)
alias wl-common='echo "/usr/share/wordlists/dirb/common.txt"'
alias wl-medium='echo "/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"'

# ==========================================
# JSON helpers
# ==========================================
alias jq-keys='jq "keys"'
alias jq-pretty='jq .'

# ==========================================
# Recon rápido
# ==========================================

# Subdomain enumeration básico
function subenum() {
    if [ -z "$1" ]; then
        echo "Usage: subenum domain.com"
        return 1
    fi
    echo "[+] Enumerating subdomains for $1..."
    # Aquí integrarías subfinder, assetfinder, etc.
    # Ejemplo placeholder:
    curl -s "https://crt.sh/?q=%25.$1&output=json" | jq -r '.[].name_value' | sort -u
}

# Probar lista de URLs con httpx
function probe() {
    if [ -z "$1" ]; then
        echo "Usage: probe urls.txt"
        return 1
    fi
    cat "$1" | httpx -silent -tech-detect -status-code -o "${1%.txt}_probed.txt"
    echo "[+] Results saved to ${1%.txt}_probed.txt"
}

# ==========================================
# Notas rápidas
# ==========================================

# Crear nota rápida con timestamp
function note() {
    local note_file="$HOME/hunting/notes/$(date +%Y-%m-%d)-quick.md"
    if [ -z "$1" ]; then
        echo "Usage: note 'tu nota aquí'"
        return 1
    fi
    echo "[$(date +%H:%M:%S)] $*" >> "$note_file"
    echo "✅ Note added to $note_file"
}

# Ver últimas notas
function notes() {
    local note_file="$HOME/hunting/notes/$(date +%Y-%m-%d)-quick.md"
    if [ -f "$note_file" ]; then
        tail -20 "$note_file"
    else
        echo "No notes for today yet."
    fi
}

# ==========================================
# Python venv helper
# ==========================================

alias venv-create='python3 -m venv venv'
alias venv-activate='source venv/bin/activate'
alias venv-deactivate='deactivate'

# Activar venv si existe en el directorio actual
function venv-auto() {
    if [ -d "venv" ]; then
        source venv/bin/activate
        echo "✅ venv activated"
    else
        echo "❌ No venv found. Create one with 'venv-create'"
    fi
}
