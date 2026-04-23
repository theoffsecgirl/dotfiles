if [[ -n "${OFFSEC_CONTAINER:-}" ]]; then
  unsetopt CORRECT
  export HUNTING_HOME="/work"
else
  export HUNTING_HOME="${HUNTING_HOME:-$HOME/hunting}"
fi

# Bug Bounty aliases y funciones
# Se carga automáticamente desde load.zsh

# ==========================================
# Wordlists — variables de entorno
# ==========================================
export WL_COMMON="${WORDLISTS:-/usr/share/wordlists}/dirb/common.txt"
export WL_MEDIUM="${WORDLISTS:-/usr/share/wordlists}/Discovery/Web-Content/directory-list-2.3-medium.txt"


# ==========================================
# Navegación rápida workspace
# ==========================================
cdh() { cd "$HUNTING_HOME"; }
cdt() { cd "$HUNTING_HOME/targets"; }
cdn() { cd "$HUNTING_HOME/notes"; }
cds() { cd "$HUNTING_HOME/scripts"; }


# ==========================================
# Helpers target/layout
# ==========================================
target_slug() {
  local raw="${1:-}"
  raw="${raw#http://}"
  raw="${raw#https://}"
  raw="${raw%%/*}"
  printf '%s' "$raw" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's#[^a-z0-9]#-#g; s#--*#-#g; s#^-##; s#-$##'
}

_target_base() {
  local slug
  slug="$(target_slug "$1")"
  printf '%s' "$HUNTING_HOME/targets/$slug"
}

mktarget() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: mktarget <dominio>"; return 1; }

  local slug base
  slug="$(target_slug "$domain")"
  base="$(_target_base "$domain")"

  mkdir -p \
    "$HUNTING_HOME/notes" \
    "$HUNTING_HOME/scripts" \
    "$base/notes" \
    "$base/recon" \
    "$base/traffic" \
    "$base/artifacts/js" \
    "$base/artifacts/responses" \
    "$base/artifacts/screenshots" \
    "$base/artifacts/exports" \
    "$base/ai" \
    "$base/reports"

  [[ -f "$base/README.md" ]] || cat > "$base/README.md" <<README
# $slug

## Scope
- $domain

## Priority
1. authz / IDOR
2. business logic
3. API inconsistencies

## Current focus

## Next step
README

  for f in overview shortlist hypotheses findings decisions; do
    [[ -f "$base/notes/$f.md" ]] || : > "$base/notes/$f.md"
  done

  [[ -f "$base/recon/resolvers.txt" ]] || cat > "$base/recon/resolvers.txt" <<'RESOLVERS'
1.1.1.1
1.0.0.1
8.8.8.8
8.8.4.4
9.9.9.9
149.112.112.112
208.67.222.222
208.67.220.220
RESOLVERS

  echo "[+] Target creado → $base"
}


# ==========================================
# Contenedores (Apple Container)
# ==========================================
export OFFSEC_CONTAINER_NAME="${OFFSEC_CONTAINER_NAME:-offsec-toolbox}"
export OFFSEC_IMAGE_NAME="${OFFSEC_IMAGE_NAME:-offsec-toolbox:latest}"
export OFFSEC_IMAGE_BASE="${OFFSEC_IMAGE_BASE:-debian:bookworm-slim}"
export OFFSEC_WORKDIR="${OFFSEC_WORKDIR:-/work}"
export OFFSEC_HOST_MOUNT="${OFFSEC_HOST_MOUNT:-$HOME/hunting}"

container-runtime() {
  command -v container >/dev/null 2>&1
}

offsec-system-start() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container system start
}

offsec-status() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container ls
}

offsec-build() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }

  local tmpdir dockerfile
  tmpdir="$(mktemp -d)" || return 1
  dockerfile="$tmpdir/Containerfile"

  cat > "$dockerfile" <<EOF
FROM ${OFFSEC_IMAGE_BASE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  ca-certificates \
  curl \
  wget \
  git \
  jq \
  vim \
  zsh \
  python3 \
  python3-pip \
  python3-venv \
  dnsutils \
  iputils-ping \
  net-tools \
  procps \
  build-essential \
  unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR ${OFFSEC_WORKDIR}
CMD ["sleep", "infinity"]
EOF

  echo "[*] Construyendo imagen ${OFFSEC_IMAGE_NAME}..."
  container build -t "${OFFSEC_IMAGE_NAME}" "$tmpdir"
  local rc=$?
  rm -rf "$tmpdir"
  return $rc
}

offsec-init() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }

  local running exists
  running="$(container ls --format json 2>/dev/null | jq -r '.[]?.name // empty' 2>/dev/null | grep -Fx "${OFFSEC_CONTAINER_NAME}" || true)"
  if [[ -n "$running" ]]; then
    echo "[+] Contenedor ya en ejecución: ${OFFSEC_CONTAINER_NAME}"
    return 0
  fi

  exists="$(container list --format json 2>/dev/null | jq -r '.[]?.name // empty' 2>/dev/null | grep -Fx "${OFFSEC_CONTAINER_NAME}" || true)"
  if [[ -n "$exists" ]]; then
    echo "[*] Arrancando contenedor existente: ${OFFSEC_CONTAINER_NAME}"
    container start "${OFFSEC_CONTAINER_NAME}"
    return $?
  fi

  [[ -d "${OFFSEC_HOST_MOUNT}" ]] || mkdir -p "${OFFSEC_HOST_MOUNT}"

  echo "[*] Creando contenedor ${OFFSEC_CONTAINER_NAME}..."
  container run -d \
    --name "${OFFSEC_CONTAINER_NAME}" \
    --volume "${OFFSEC_HOST_MOUNT}:${OFFSEC_WORKDIR}" \
    --workdir "${OFFSEC_WORKDIR}" \
    "${OFFSEC_IMAGE_NAME}" \
    sleep infinity
}

offsec() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  offsec-init || return 1
  container exec -it "${OFFSEC_CONTAINER_NAME}" zsh
}

offsec-start() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  offsec-init
}

offsec-stop() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container stop "${OFFSEC_CONTAINER_NAME}"
}

offsec-logs() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container logs "${OFFSEC_CONTAINER_NAME}"
}

offsec-rm() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container rm "${OFFSEC_CONTAINER_NAME}"
}

offsec-rebuild() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  offsec-stop >/dev/null 2>&1 || true
  offsec-rm >/dev/null 2>&1 || true
  offsec-build || return 1
  offsec-init
}


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


# ==========================================
# Recon rápido
# ==========================================
subenum() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: subenum <dominio.com>"; return 1; }

  local base outdir outfile
  base="$(_target_base "$domain")"
  outdir="$base/recon"
  outfile="$outdir/subdomains.txt"
  mkdir -p "$outdir"

  echo "[*] Enumerando subdominios para $domain..."

  (
    if command -v subfinder >/dev/null 2>&1; then
      subfinder -silent -d "$domain" -all 2>/dev/null
    fi

    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
      curl -sf --max-time 15 "https://crt.sh/?q=%25.${domain}&output=json" 2>/dev/null \
        | jq -r 'if type == "array" then .[].name_value else empty end' 2>/dev/null \
        | tr ',' '\n'
    fi
  ) | sed 's/^\*\.//' | tr '[:upper:]' '[:lower:]' | sort -u | tee "$outfile"

  echo "[+] Subdominios guardados → $outfile"
}

probe() {
  local input="${1:-}"
  [[ -z "$input" ]] && { echo "Uso: probe <urls.txt>"; return 1; }
  [[ ! -f "$input" ]] && { echo "[!] Fichero no encontrado: $input"; return 1; }
  local out="$(dirname "$input")/probed.txt"
  httpx -silent -tech-detect -status-code -l "$input" -o "$out"
  echo "[+] Resultados → $out"
}

inscope() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: inscope <dominio.com>"; return 1; }
  local base="$(_target_base "$domain")"
  local scope_file="$base/recon/scope.txt"
  local subs_file="$base/recon/subdomains.txt"
  [[ ! -f "$scope_file" ]] && { echo "[!] Fichero de scope no encontrado: $scope_file"; return 1; }
  [[ ! -f "$subs_file" ]] && { echo "[!] Ejecuta primero: subenum $domain"; return 1; }
  grep -Ff "$scope_file" "$subs_file"
}

recon() {
  local domain="${1:-}"
  [[ -z "$domain" ]] && { echo "Uso: recon <dominio.com>"; return 1; }
  mktarget "$domain" >/dev/null
  subenum "$domain"
  local subs="$(_target_base "$domain")/recon/subdomains.txt"
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
  nuclei -silent -l "$input" -tags cve -o "$out"
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


# Compatibilidad explícita con el nombre antiguo sin pisar el binario scope
alias scope-filter=inscope

# ==========================================
# Tips — cheatsheet interactivo de aliases y atajos
# ==========================================
tips() {
  emulate -L zsh
  setopt local_options extended_glob no_aliases

  local content=""
  local fn

  _tips_section() {
    local title="$1"
    content+=$'\n'
    content+="=== ${title} ===\n"
  }

  _tips_alias() {
    local name="$1"
    local note="$2"
    [[ -n "${aliases[$name]:-}" ]] || return 0
    local line
    printf -v line '%-18s -> %-45s # %s\n' "$name" "${aliases[$name]}" "$note"
    content+="$line"
  }

  _tips_func() {
    local name="$1"
    local note="$2"
    (( $+functions[$name] )) || return 0
    local line
    printf -v line '%-18s -> %-45s # %s\n' "$name" "función" "$note"
    content+="$line"
  }

  content+="tips — aliases y funciones cargadas\n"
  content+="ESC para salir | escribe para filtrar\n"

  _tips_section "GIT"
  _tips_alias gs "estado corto"
  _tips_alias gl "log gráfico"
  _tips_alias gd "diff actual"
  _tips_alias gds "diff staged"
  _tips_alias gc "commit rápido"
  _tips_alias gca "amend último commit"
  _tips_alias gst "stash"
  _tips_alias gstp "stash pop"
  _tips_alias gb "ramas verbosas"
  _tips_alias glog "log global"

  _tips_section "NAVEGACIÓN"
  if (( $+commands[z] )) || (( $+functions[z] )); then
    content+="z                  -> comando                                       # saltar a directorio frecuente (zoxide)\n"
  fi
  if (( $+commands[zi] )) || (( $+functions[zi] )); then
    content+="zi                 -> comando                                       # selector interactivo de directorios\n"
  fi
  _tips_alias dotfiles "ir a ~/.dotfiles"
  _tips_alias hunting "ir a ~/hunting"
  _tips_alias .. "subir 1 nivel"
  _tips_alias ... "subir 2 niveles"
  _tips_alias .... "subir 3 niveles"
  _tips_func cdh "ir a HUNTING_HOME"
  _tips_func cdt "ir a targets"
  _tips_func cdn "ir a notas globales"
  _tips_func cds "ir a scripts"

  _tips_section "BUG BOUNTY"
  _tips_func mktarget "crear target simple y consistente"
  _tips_func subenum "enumera subdominios"
  _tips_func probe "httpx sobre lista"
  _tips_func recon "mktarget + subenum + probe"
  _tips_func inscope "filtra subdominios in-scope"
  _tips_func note "añadir nota rápida global"
  _tips_func notes "ver notas de hoy"
  _tips_alias scope-filter "compat alias antiguo"

  _tips_section "CONTAINER"
  _tips_func offsec-system-start "arranca servicios de Apple Container"
  _tips_func offsec-build "construye imagen offsec-toolbox"
  _tips_func offsec-init "crea o arranca el contenedor"
  _tips_func offsec "entra al contenedor toolbox"
  _tips_func offsec-start "arranca toolbox"
  _tips_func offsec-stop "para toolbox"
  _tips_func offsec-rebuild "reconstruye imagen y contenedor"
  _tips_func offsec-logs "logs del contenedor"
  _tips_func offsec-status "lista contenedores"
  _tips_func offsec-rm "borra el contenedor"

  _tips_section "HTTP"
  _tips_alias h "httpx básico"
  _tips_alias hh "httpx con tech y status"
  _tips_alias hhh "httpx con title y webserver"
  _tips_alias ch "curl solo headers"
  _tips_alias hget "HTTP GET"
  _tips_alias hpost "HTTP POST"
  _tips_alias f "ffuf base"
  _tips_alias nuc "nuclei -silent"

  _tips_section "PYTHON"
  _tips_alias py "python3"
  _tips_alias pip "pip3 fuera de venv"
  _tips_alias venv-create "crear venv"
  _tips_alias venv-activate "activar venv"
  _tips_alias venv-deactivate "desactivar venv"
  _tips_func venv-auto "activar venv o .venv si existe"

  _tips_section "UTILIDADES"
  _tips_alias ll "ls largo"
  _tips_alias la "ls ocultos"
  _tips_alias duu "uso de disco ordenado"
  _tips_alias ports "puertos activos"
  _tips_alias myip "IP pública"
  _tips_alias localip "IP local"
  _tips_alias path "PATH línea por línea"
  _tips_alias reload "recargar shell"

  _tips_section "FUNCIONES CUSTOM"
  for fn in cdh cdt cdn cds mktarget subenum probe inscope recon nucl note notes venv-auto tips offsec-system-start offsec-build offsec-init offsec offsec-start offsec-stop offsec-rebuild offsec-logs offsec-status offsec-rm; do
    (( $+functions[$fn] )) || continue
    content+="$fn                 -> función                                       # custom\n"
  done

  if command -v fzf >/dev/null 2>&1; then
    printf '%b' "$content" | fzf --ansi --layout=reverse --no-sort --header='tips — aliases y funciones cargadas · ESC para salir'
  else
    printf '%b' "$content" | less -R
  fi
}
