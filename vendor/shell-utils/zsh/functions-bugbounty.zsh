# Funciones de seguridad ofensiva, proyectos y utilidades (UNIFICADO)
# Fuente A: /mnt/data/functions-bugbounty.zsh (antiguo, versión completa)
# Fuente B: contenido pegado en el chat (nuevo; incluía placeholder en subscan)
# Objetivo: no perder nada. Preferimos implementación completa cuando hay conflicto.

# -------------------------
# Actualización de sistema según plataforma/distro
# -------------------------
update_system() {
    if [[ "$PLATFORM" == "macos" ]]; then
        brew update && brew upgrade && brew cleanup
        softwareupdate -l
    else
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        elif command -v dnf &> /dev/null; then
            sudo dnf upgrade -y && sudo dnf autoremove -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -Syu --noconfirm
        fi
    fi
}
alias update='update_system'


# -------------------------
# mkproject: crear proyectos y subcarpetas (hunting)
# -------------------------
mkproject() {
  set -euo pipefail

  local input="${1:-}"
  if [[ -z "$input" ]]; then
    echo "Uso: mkproject dominio.com"
    return 1
  fi

  # --- Normalización ---
  local domain="$input"
  domain="${domain#http://}"
  domain="${domain#https://}"
  domain="${domain#*.}"
  domain="${domain%%/*}"
  domain="${domain:l}"

  local base="$HOME/hunting/targets/$domain"

  mkdir -p "$base"/{in,out,tmp,notes}

  cd "$base" || return 1

  # -------------------------
  # resolvers.txt
  # -------------------------
  cat > "in/resolvers.txt" <<'EOF'
1.1.1.1
1.0.0.1
8.8.8.8
8.8.4.4
9.9.9.9
149.112.112.112
208.67.222.222
208.67.220.220
EOF

  # -------------------------
  # notes/README.md
  # -------------------------
  cat > "notes/README.md" <<EOF
# $domain

## Scope
- Programa:
- Tipo: Bug Bounty / VDP
- Wildcards:
- Excluded assets:

## Notas iniciales
- DNS provider:
- Cloud provider:
- Tecnologías detectadas:

## Recon
- Subs totales:
- Hosts vivos:
- Señales takeover:

## Hallazgos
- [ ] 
- [ ] 

## Decisiones técnicas
EOF

  # -------------------------
  # dns-pipeline.sh
  # -------------------------
  cat > "dns-pipeline.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "Uso: $0 dominio.com"
  exit 1
fi

ROOT="$(pwd)"
IN="$ROOT/in"
OUT="$ROOT/out"
TMP="$ROOT/tmp"

mkdir -p "$IN" "$OUT" "$TMP"

RESOLVERS="$IN/resolvers.txt"
[[ -f "$RESOLVERS" ]] || { echo "Falta $RESOLVERS"; exit 1; }

echo "[*] 1) Enumeración pasiva"
subfinder -silent -d "$DOMAIN" -all -recursive | tee "$TMP/subfinder.txt" >/dev/null || true
amass enum -passive -d "$DOMAIN" 2>/dev/null | tee "$TMP/amass.txt" >/dev/null || true

if command -v assetfinder >/dev/null 2>&1; then
  assetfinder --subs-only "$DOMAIN" | tee "$TMP/assetfinder.txt" >/dev/null || true
else
  : > "$TMP/assetfinder.txt"
fi

cat "$TMP/subfinder.txt" "$TMP/amass.txt" "$TMP/assetfinder.txt" \
  | sed 's/^\*\.\?//' \
  | tr '[:upper:]' '[:lower:]' \
  | awk 'NF' \
  | sort -u \
  | tee "$OUT/subs.all.txt" >/dev/null

echo "[*] 2) Wildcard DNS"
RND="wildcard-$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 16)"
WILDCARD_IPS="$(dig +short "${RND}.${DOMAIN}" A | tr '\n' ' ')"

if [[ -n "$WILDCARD_IPS" ]]; then
  echo "[!] Wildcard detectado: ${WILDCARD_IPS}"
  echo "$WILDCARD_IPS" > "$OUT/wildcard.ips.txt"
else
  : > "$OUT/wildcard.ips.txt"
fi

echo "[*] 3) Resolución DNS"
puredns resolve "$OUT/subs.all.txt" -r "$RESOLVERS" -w "$OUT/subs.resolved.txt" >/dev/null 2>&1 || true

dnsx -l "$OUT/subs.resolved.txt" -silent -a -aaaa -cname -resp \
  | tee "$OUT/dns.enriched.txt" >/dev/null

cut -d ' ' -f1 "$OUT/dns.enriched.txt" | sort -u > "$OUT/hosts.live.txt"

awk 'BEGIN{IGNORECASE=1} $0 ~ / cname / {print $1, $0}' "$OUT/dns.enriched.txt" \
  | sed 's/.* cname //' \
  | awk '{print $1, $2}' \
  | sort -u > "$OUT/hosts.cname.map.txt" || true

echo "[*] 4) HTTP discovery"
httpx -l "$OUT/hosts.live.txt" -silent -follow-redirects -title -tech-detect -status-code -web-server -content-type \
  | tee "$OUT/httpx.live.txt" >/dev/null

cut -d ' ' -f1 "$OUT/httpx.live.txt" | sort -u > "$OUT/urls.live.txt"

echo "[*] 5) Takeover heurísticas"
grep -Ei "No such app|There isn't a GitHub Pages site here|Bucket.*does not exist|project not found|Domain isn't configured" \
  "$OUT/httpx.live.txt" > "$OUT/takeover.signals.txt" || true

echo "[*] 6) Nuclei"
if [[ -s "$OUT/urls.live.txt" ]]; then
  nuclei -l "$OUT/urls.live.txt" -silent -severity low,medium,high,critical \
    -tags takeover,dns,misconfig,tech \
    | tee "$OUT/nuclei.findings.txt" >/dev/null || true
else
  : > "$OUT/nuclei.findings.txt"
fi

echo "[*] Listo."
EOF

  chmod +x "dns-pipeline.sh"

  echo "[✔] Proyecto creado en: $base"
  echo "[→] Ejecuta: ./dns-pipeline.sh $domain"

  # -------------------------
  # Lanzar tmux-recon si existe
  # -------------------------
  if command -v tmux-recon >/dev/null 2>&1; then
    echo "[→] Lanzando tmux-recon..."
    tmux-recon "recon-$domain" "$base"
  fi
}


# -------------------------
# mkproject_template: crear proyectos con plantillas
# -------------------------
mkproject_template() {
    if [[ $# -lt 2 ]]; then
        echo "Uso: mkproject_template nombre_proyecto plantilla"
        echo "Plantillas disponibles: docencia, bugbounty, ctf"
        return 1
    fi

    local proj="$1"
    local tpl="$2"

    case "$tpl" in
        docencia)
            mkdir -p "$proj"/{actividades,labs,scripts}
            {
              echo "# Docencia: $proj"
              echo "- Actividades: ejercicios y tareas"
              echo "- Labs: prácticas guiadas"
              echo "- Scripts: utilidades y herramientas"
            } > "$proj/README.md"
            ;;

        bugbounty)
            mkdir -p "$proj"/{recon,enumeration,scans,exploits,pocs,wordlists,screenshots,notes,reports,loot}
            {
              echo "# Bug Bounty: $proj"
              echo "- Recon: subdominios/hosts"
              echo "- Enumeration: info detallada"
              echo "- Scans: nmap, nuclei, ffuf…"
              echo "- Exploits/Pocs: scripts o PoCs"
              echo "- Wordlists: listas específicas"
              echo "- Screenshots: pruebas visuales"
              echo "- Notes: findings y procesos"
              echo "- Reports: borradores y entregables"
              echo "- Loot: credenciales, datos…"
            } > "$proj/README.md"
            ;;

        ctf)
            mkdir -p "$proj"/{src,flags,writeups,notes}
            {
              echo "# CTF: $proj"
              echo "- src: exploits/scripts"
              echo "- flags: resultados CTF"
              echo "- writeups: soluciones"
              echo "- notes: apuntes rápidos"
            } > "$proj/README.md"
            ;;

        *)
            echo "Plantilla desconocida: $tpl"
            echo "Opciones válidas: docencia, bugbounty, ctf"
            return 2
            ;;
    esac

    echo "Proyecto '$proj' creado con plantilla '$tpl'."
}


# -------------------------
# extra: descompresión automática según extensión
# -------------------------
extra() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1" ;;
            *.tar.gz)    tar xzf "$1" ;;
            *.tar.xz)    tar xJf "$1" ;;
            *.tar)       tar xf "$1" ;;
            *.tbz2)      tar xjf "$1" ;;
            *.tgz)       tar xzf "$1" ;;
            *.zip)       unzip "$1" ;;
            *.rar)       unrar x "$1" ;;
            *.7z)        7z x "$1" ;;
            *.gz)        gunzip "$1" ;;
            *.bz2)       bunzip2 "$1" ;;
            *)           echo "'$1' no puede ser extraído vía extra()" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}


# -------------------------
# extractips: extrae IPs únicas del dir actual
# -------------------------
extractips() {
    grep -Eroh '([0-9]{1,3}\.){3}[0-9]{1,3}' . | sort -u
}


# -------------------------
# quickvenv: crea y activa un venv en .venv
# -------------------------
quickvenv() {
    python3 -m venv .venv && source .venv/bin/activate
    echo "Virtualenv .venv activado"
}


# -------------------------
# gotodir: busca directorio y entra
# -------------------------
gotodir() {
    dir=$(find . -type d -iname "*$1*" | head -n 1)
    if [[ -d "$dir" ]]; then
        cd "$dir"
        echo "Entro en $dir"
    else
        echo "No encontrado"
    fi
}


# -------------------------
# updateall: actualiza sistema + pip + plugins Neovim
# -------------------------
updateall() {
    update_system
    pip3 install --upgrade pip setuptools wheel

    if command -v nvim &>/dev/null; then
        nvim --headless "+Lazy! sync" +qa
    fi

    echo "Todo actualizado: sistema, pip y plugins de Neovim (si hay)."
}


# -------------------------
# subscan: subfinder + httpx con output bonito
# -------------------------
# Nota de unificación:
# - En el “nuevo” pegado, aquí había un placeholder:
#   python3 - "$1" <<'PYCODE'
#   # (el código python queda igual, no lo toco porque está perfecto)
#   PYCODE
# - En el “antiguo” subido, el código Python estaba completo. Se conserva esa versión (la buena).

subscan() {
    if [ -z "$1" ]; then
        echo "Uso: subscan <dominio.com>"
        return 1
    fi

    python3 - "$1" <<'PYCODE'
import sys, shutil, subprocess, threading, json, signal, socket
from urllib.parse import urlparse
from functools import lru_cache

def tty(): return sys.stdout.isatty()
def c(s, code): return f"\x1b[{code}m{s}\x1b[0m" if tty() else s
BOLD=lambda s:c(s,"1"); RED=lambda s:c(s,"31"); GRN=lambda s:c(s,"32")
YEL=lambda s:c(s,"33"); BLU=lambda s:c(s,"34"); CYN=lambda s:c(s,"36")

PORTS = "80,443,8080,8443"
HTTPX_ARGS = [
    'httpx','-silent','-follow-redirects','-status-code','-title','-ip','-ports',PORTS,'-json','-threads','200'
]

stop_event = threading.Event()
def handle_sigint(sig, frame):
    stop_event.set()
    print(YEL("\n[!] Interrumpido por el usuario"))
signal.signal(signal.SIGINT, handle_sigint)
signal.signal(signal.SIGTERM, handle_sigint)

def truncate(s, n=60):
    s = s or ""
    return s if len(s) <= n else s[:n-1] + "…"

def which(cmd): return shutil.which(cmd) is not None

def run(cmd, input_text=None, timeout=None):
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE if input_text else None, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        out, err = p.communicate(input=input_text, timeout=timeout)
    except subprocess.TimeoutExpired:
        p.kill()
        out, err = p.communicate()
        return 124, out, err
    return p.returncode, out, err

@lru_cache(maxsize=256)
def is_port_open(host, port, timeout=0.4):
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except Exception:
        return False

domain = sys.argv[1].strip()
if not domain:
    print("Uso: subscan <dominio.com>")
    sys.exit(1)

need = ["subfinder","httpx"]
missing = [x for x in need if not which(x)]
if missing:
    print(RED("[x] Faltan binarios: ") + ", ".join(missing))
    sys.exit(2)

print(BOLD(f"[*] Enumerando subdominios para {domain}"))
rc, subs, err = run(["subfinder","-silent","-d",domain,"-all","-recursive"])
subs = "\n".join(sorted({s.strip().lower().lstrip("*.") for s in subs.splitlines() if s.strip()}))
if not subs.strip():
    print(YEL("[!] No se encontraron subdominios"))
    sys.exit(0)

print(BOLD("[*] Descubriendo HTTP(S) con httpx"))
rc, out, err = run(HTTPX_ARGS, input_text=subs)
rows = []
for line in out.splitlines():
    try:
        rows.append(json.loads(line))
    except Exception:
        continue

# Tabla simple
print(BOLD("\nURL".ljust(52) + "SC".ljust(5) + "IP".ljust(18) + "TITLE"))
print("-"*100)

for r in rows:
    url = r.get("url","")
    sc  = str(r.get("status_code",""))
    ip  = r.get("host","") or r.get("ip","")
    title = truncate(r.get("title",""), 42)
    print(url.ljust(52) + sc.ljust(5) + str(ip).ljust(18) + title)

print(GRN(f"\n[+] Encontrados {len(rows)} endpoints con respuesta HTTP"))
PYCODE
}


# -------------------------
# ffufdirs: fuzz de directorios
# -------------------------
ffufdirs() {
    ffuf -u "https://$1/FUZZ" \
         -w "$WORDLISTS/fuzz4bounty/fuzz4bounty/dirsearch.txt" \
         -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}


# -------------------------
# ffufparams: fuzzing de parámetros
# -------------------------
ffufparams() {
    ffuf -u "https://$1/page.php?FUZZ=1" \
         -w "$WORDLISTS/fuzz4bounty/discovery/parameter.txt" \
         -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}


# -------------------------
# subfinderall: enumeración ampliada
# -------------------------
subfinderall() {
    command subfinder -d "$1" -all -t 100 -v -o "subs_${1}.txt"
}


# -------------------------
# ctfwriteup: carpeta + md + abre en nvim
# -------------------------
ctfwriteup() {
    mkdir -p "$1" && echo "# $1" > "$1/writeup.md" && nvim "$1/writeup.md"
}


# -------------------------
# aliases(): buscador de alias
# -------------------------
aliases() {
    if [[ -z "$1" ]]; then
        alias | sort
    else
        alias | grep -i --color "$1"
    fi
}
