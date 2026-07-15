# bug-bounty.zsh — workspace y helpers de bug bounty
# Cargado automáticamente desde load.zsh
#
# HUNTING_HOME: define la raíz de tu workspace.
# El valor real debe estar en ~/.config/zsh/local.zsh (no versionado):
#
#   export HUNTING_HOME="$HOME/Library/Mobile Documents/com~apple~CloudDocs/02_PROFESIONAL/bugbounty"
#
# El fallback aquí es solo para el contenedor offsec y para máquinas
# sin local.zsh configurado. No depende de rutas con espacios ni emojis.

if [[ -n "${OFFSEC_CONTAINER:-}" ]]; then
  unsetopt CORRECT
  export HUNTING_HOME="/work"
else
  export ICLOUD_HOME="${ICLOUD_HOME:-$HOME/Library/Mobile Documents/com~apple~CloudDocs}"
  # Fallback seguro: ~/hunting como RAÍZ del workspace (los targets viven en
  # $HUNTING_HOME/targets/). Sin emojis ni espacios, funciona en todos los tools.
  # Antes era ~/targets, lo que producía la ruta duplicada ~/targets/targets/<t>.
  export HUNTING_HOME="${HUNTING_HOME:-$HOME/hunting}"
fi

export GLOBAL_NOTES_HOME="${GLOBAL_NOTES_HOME:-$HUNTING_HOME/notes}"

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
cdn() { cd "$GLOBAL_NOTES_HOME"; }
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

_current_target_base() {
  local targets_root="${HUNTING_HOME:-$HOME/hunting}/targets"
  local current="${PWD:A}"
  local root="${targets_root:A}"

  [[ "$current" == "$root"/* ]] || return 1

  local rel="${current#$root/}"
  local slug="${rel%%/*}"

  [[ -n "$slug" && -d "$root/$slug" ]] || return 1
  printf '%s' "$root/$slug"
}

_target_note_file() {
  local target_base="$1"
  local kind="${2:-daily}"

  case "$kind" in
    daily|quick|target)
      printf '%s' "$target_base/notes/$(date +%Y-%m-%d)-target.md"
      ;;
    overview|shortlist|hypotheses|findings|decisions)
      printf '%s' "$target_base/notes/$kind.md"
      ;;
    *)
      return 1
      ;;
  esac
}


# ==========================================
# Contenedores (Apple Container)
# ==========================================
export OFFSEC_CONTAINER_NAME="${OFFSEC_CONTAINER_NAME:-offsec-toolbox}"
export OFFSEC_IMAGE_NAME="${OFFSEC_IMAGE_NAME:-offsec-toolbox:latest}"
export OFFSEC_IMAGE_BASE="${OFFSEC_IMAGE_BASE:-debian:bookworm-slim}"
export OFFSEC_WORKDIR="${OFFSEC_WORKDIR:-/work}"
export OFFSEC_HOST_MOUNT="${OFFSEC_HOST_MOUNT:-$HUNTING_HOME}"

container-runtime() {
  command -v container >/dev/null 2>&1
}

offsec-system-start() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container system start
}

offsec-container-status() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container ls
}

offsec-container-build() {
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

offsec-container-init() {
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

offsec-container() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  offsec-init || return 1
  container exec -it "${OFFSEC_CONTAINER_NAME}" zsh
}

offsec-container-start() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  offsec-init
}

offsec-container-stop() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container stop "${OFFSEC_CONTAINER_NAME}"
}

offsec-container-logs() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container logs "${OFFSEC_CONTAINER_NAME}"
}

offsec-container-rm() {
  container-runtime || { echo "[!] Apple Container no está instalado"; return 1; }
  container rm "${OFFSEC_CONTAINER_NAME}"
}

offsec-container-rebuild() {
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
# DEPRECADO — usa: scope <dominio> (pipeline v2: http/httpx.jsonl + http/live.txt)
subenum() {
  printf '\033[1;33m[!]\033[0m %s\n' "DEPRECADO: subenum → usa scope <dominio> o scope-program <programa>" >&2
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

# DEPRECADO — genera recon/probed.txt; el pipeline v2 espera http/httpx.jsonl + http/live.txt
probe() {
  printf '\033[1;33m[!]\033[0m %s\n' "DEPRECADO: probe → el pipeline v2 usa httpx via scope/scope-program (salida en http/httpx.jsonl)" >&2
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

# DEPRECADO — usa: scope <dominio> o program-init + scope-program para programas multi-dominio
recon() {
  printf '\033[1;33m[!]\033[0m %s\n' "DEPRECADO: recon → usa scope <dominio> (o program-init + scope-program para programas)" >&2
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
  local note_file="${GLOBAL_NOTES_HOME:-$HUNTING_HOME/notes}/$(date +%Y-%m-%d)-quick.md"
  mkdir -p "$(dirname "$note_file")"
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >> "$note_file"
  echo "✅ Nota añadida → $note_file"
}

tnote() {
  local kind="daily"
  local edit=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--file)
        shift
        [[ -z "${1:-}" ]] && { echo "Uso: tnote -f <overview|shortlist|hypotheses|findings|decisions> 'nota'"; return 1; }
        kind="$1"
        ;;
      -o|--open)
        edit=1
        ;;
      -h|--help)
        echo "Uso: tnote [-o] [-f overview|shortlist|hypotheses|findings|decisions] 'nota del target actual'"
        return 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "[!] Flag no soportado: $1"
        return 1
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  local target_base
  target_base="$(_current_target_base)" || {
    echo "[!] No estás dentro de ${HUNTING_HOME:-$HOME/hunting}/targets/<target>"
    return 1
  }

  local note_file
  note_file="$(_target_note_file "$target_base" "$kind")" || {
    echo "[!] Fichero no soportado: $kind"
    echo "    Usa: overview, shortlist, hypotheses, findings, decisions"
    return 1
  }

  mkdir -p "$(dirname "$note_file")"

  if (( edit )); then
    "${EDITOR:-vim}" "$note_file"
    return $?
  fi

  [[ -z "${*:-}" ]] && { echo "Uso: tnote [-f <file>] 'nota del target actual'"; return 1; }

  printf '\n- [%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$*" >> "$note_file"
  echo "✅ Nota target añadida → $note_file"
}

tnotes() {
  local kind="daily"

  if [[ "${1:-}" == "-f" || "${1:-}" == "--file" ]]; then
    shift
    [[ -z "${1:-}" ]] && { echo "Uso: tnotes -f <overview|shortlist|hypotheses|findings|decisions>"; return 1; }
    kind="$1"
  fi

  local target_base
  target_base="$(_current_target_base)" || {
    echo "[!] No estás dentro de ${HUNTING_HOME:-$HOME/hunting}/targets/<target>"
    return 1
  }

  local note_file
  note_file="$(_target_note_file "$target_base" "$kind")" || {
    echo "[!] Fichero no soportado: $kind"
    echo "    Usa: overview, shortlist, hypotheses, findings, decisions"
    return 1
  }

  if [[ -f "$note_file" ]]; then
    tail -30 "$note_file"
  else
    echo "No hay notas en: $note_file"
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
