if [[ -n "${OFFSEC_CONTAINER:-}" ]]; then
  unsetopt CORRECT
  export HUNTING_HOME="/work"
else
  export HUNTING_HOME="${HUNTING_HOME:-$HOME/hunting}"
fi

# Bug Bounty aliases y funciones
# Se carga automáticamente desde load.zsh

# ==========================================
# Navegación rápida workspace
# ==========================================
cdh() { cd "$HUNTING_HOME"; }
cdt() { cd "$HUNTING_HOME/targets"; }
cdn() { cd "$HUNTING_HOME/notes"; }
cds() { cd "$HUNTING_HOME/scripts"; }


# ==========================================
# Contenedores
# ==========================================
export OFFSEC_CONTAINER_NAME="${OFFSEC_CONTAINER_NAME:-offsec-toolbox}"
alias offsec='docker exec -it ${OFFSEC_CONTAINER_NAME} zsh'
alias offsec-restart='cd ${DOTFILES_DIR:-~/.dotfiles}/containers/debian-toolbox && docker compose restart'
alias offsec-rebuild='cd ${DOTFILES_DIR:-~/.dotfiles}/containers/debian-toolbox && docker compose down && docker compose build --no-cache && docker compose up -d'


# ==========================================
# HTTP shortcuts
# ==========================================
alias h='httpx -silent'
alias hh='httpx -silent -tech-detect -status-code'
alias hhh='httpx -silent -tech-detect -status-code -title -web-server'

alias ch='curl -sI'
alias hget='http GET'
alias hpost='http POST'


# ==========================================
# Fuzzing
# ==========================================
alias f='ffuf -c -mc all -fc 404'

# Wordlists rápidas (referencia)
wl-common() { echo "${WORDLISTS:-/usr/share/wordlists}/dirb/common.txt"; }
wl-medium()  { echo "${WORDLISTS:-/usr/share/wordlists}/Discovery/Web-Content/directory-list-2.3-medium.txt"; }


# ==========================================
# JSON helpers
# ==========================================
alias jq-keys='jq "keys"'
alias jq-pretty='jq .'


# ==========================================
# Recon rápido
# ==========================================

# Subdomain enumeration: subfinder + crt.sh deduplicados
subenum() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: subenum <dominio.com>"; return 1; }

  local outdir="$HUNTING_HOME/targets/$domain"
  local outfile="$outdir/subdomains.txt"
  mkdir -p "$outdir"

  echo "[*] Enumerando subdominios para $domain..."

  (
    if command -v subfinder >/dev/null 2>&1; then
      subfinder -silent -d "$domain" -all 2>/dev/null
    fi

    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
      curl -s --max-time 15 "https://crt.sh/?q=%25.${domain}&output=json" 2>/dev/null \
        | jq -r '.[].name_value' 2>/dev/null \
        | tr ',' '\n'
    fi
  ) | sed 's/^\*\.//' | tr '[:upper:]' '[:lower:]' | sort -u | tee "$outfile"

  echo "[+] Subdominios guardados → $outfile"
}

# Probar lista de URLs con httpx
probe() {
  local input="${1:-}"
  [[ -z "$input" ]] && { echo "Uso: probe <urls.txt>"; return 1; }
  [[ ! -f "$input" ]] && { echo "[!] Fichero no encontrado: $input"; return 1; }
  local out="${input%.txt}_probed.txt"
  httpx -silent -tech-detect -status-code -l "$input" -o "$out"
  echo "[+] Resultados → $out"
}

# Filtrar subdominios in-scope para un dominio
scope() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: scope <dominio.com>"; return 1; }
  local scope_file="$HUNTING_HOME/targets/$domain/scope.txt"
  local subs_file="$HUNTING_HOME/targets/$domain/subdomains.txt"
  [[ ! -f "$scope_file" ]] && { echo "[!] Fichero de scope no encontrado: $scope_file"; return 1; }
  [[ ! -f "$subs_file" ]] && { echo "[!] Ejecuta primero: subenum $domain"; return 1; }
  grep -Ff "$scope_file" "$subs_file"
}

# Recon completo: subenum → probe → nota
recon() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: recon <dominio.com>"; return 1; }
  subenum "$domain"
  local subs="$HUNTING_HOME/targets/$domain/subdomains.txt"
  [[ -f "$subs" ]] && probe "$subs"
  note "recon completado para $domain"
}


# ==========================================
# Nuclei
# ==========================================
alias nuc='nuclei -silent'

nucl() {
  local input="${1:-}"
  [[ -z "$input" ]] && { echo "Uso: nucl <urls.txt>"; return 1; }
  local out="${input%.txt}-nuclei.txt"
  nuclei -silent -l "$input" -t cves/ -o "$out"
  echo "[+] Resultados → $out"
}


# ==========================================
# Notas rápidas
# ==========================================
note() {
  [[ -z "${*:-}" ]] && { echo "Uso: note 'tu nota aquí'"; return 1; }
  local note_file="${HUNTING_HOME:-$HOME/hunting}/notes/$(date +%Y-%m-%d)-quick.md"
  mkdir -p "$(dirname "$note_file")"
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >> "$note_file"
  echo "✅ Nota añadida → $note_file"
}

notes() {
  local note_file="${HUNTING_HOME:-$HOME/hunting}/notes/$(date +%Y-%m-%d)-quick.md"
  if [[ -f "$note_file" ]]; then
    tail -20 "$note_file"
  else
    echo "No hay notas de hoy."
  fi
}


# ==========================================
# Python venv helpers
# ==========================================
alias venv-create='python3 -m venv venv'
alias venv-activate='source venv/bin/activate'
alias venv-deactivate='deactivate'

venv-auto() {
  if [[ -d venv ]]; then
    source venv/bin/activate
    echo "✅ venv activado"
  elif [[ -d .venv ]]; then
    source .venv/bin/activate
    echo "✅ .venv activado"
  else
    echo "❌ No se encontró venv ni .venv. Crea uno con: venv-create"
  fi
}
