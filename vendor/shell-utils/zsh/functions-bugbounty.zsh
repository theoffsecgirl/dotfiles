# Funciones de seguridad ofensiva, proyectos y utilidades

# -------------------------
# Actualización de sistema
# -------------------------
update_system() {
    if [[ "$PLATFORM" == "macos" ]]; then
        brew update && brew upgrade && brew cleanup
        softwareupdate -l
    else
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        elif command -v dnf &>/dev/null; then
            sudo dnf upgrade -y && sudo dnf autoremove -y
        elif command -v pacman &>/dev/null; then
            sudo pacman -Syu --noconfirm
        fi
    fi
}
alias update='update_system'


# -------------------------
# mkproject: crear proyectos de hunting con pipeline DNS
# -------------------------
mkproject() {
  set -euo pipefail

  local input="${1:-}"
  if [[ -z "$input" ]]; then
    echo "Uso: mkproject dominio.com"
    return 1
  fi

  local domain="$input"
  domain="${domain#http://}"
  domain="${domain#https://}"
  domain="${domain#*.}"
  domain="${domain%%/*}"
  domain="${domain:l}"

  local base="$HOME/hunting/targets/$domain"

  mkdir -p "$base"/{in,out,tmp,notes,recon,http,fuzz,js,burp,reports,loot}

  cat > "$base/in/resolvers.txt" <<'EOF'
1.1.1.1
1.0.0.1
8.8.8.8
8.8.4.4
9.9.9.9
149.112.112.112
208.67.222.222
208.67.220.220
EOF

  cat > "$base/notes/README.md" <<EOF
# $domain

## Scope
- Programa:
- Tipo: Bug Bounty / VDP
- Wildcards:
- Excluded assets:

## Recon
- Subs totales:
- Hosts vivos:
- Señales takeover:

## Hallazgos
- [ ]

## Decisiones técnicas
EOF

  cat > "$base/dns-pipeline.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-}"
[[ -z "$DOMAIN" ]] && { echo "Uso: $0 dominio.com"; exit 1; }

ROOT="$(pwd)"
IN="$ROOT/in"; OUT="$ROOT/out"; TMP="$ROOT/tmp"
mkdir -p "$IN" "$OUT" "$TMP"
RESOLVERS="$IN/resolvers.txt"
[[ -f "$RESOLVERS" ]] || { echo "Falta $RESOLVERS"; exit 1; }

echo "[*] 1) Enumeración pasiva"
subfinder -silent -d "$DOMAIN" -all -recursive | tee "$TMP/subfinder.txt" >/dev/null || true
amass enum -passive -d "$DOMAIN" 2>/dev/null | tee "$TMP/amass.txt" >/dev/null || true
command -v assetfinder >/dev/null 2>&1 && \
  assetfinder --subs-only "$DOMAIN" | tee "$TMP/assetfinder.txt" >/dev/null || : > "$TMP/assetfinder.txt"

cat "$TMP/subfinder.txt" "$TMP/amass.txt" "$TMP/assetfinder.txt" \
  | sed 's/^\*\.\?//' | tr '[:upper:]' '[:lower:]' | awk 'NF' | sort -u \
  | tee "$OUT/subs.all.txt" >/dev/null

echo "[*] 2) Wildcard DNS"
RND="wildcard-$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 16)"
WILDCARD_IPS="$(dig +short "${RND}.${DOMAIN}" A | tr '\n' ' ')"
[[ -n "$WILDCARD_IPS" ]] && echo "[!] Wildcard: $WILDCARD_IPS" && echo "$WILDCARD_IPS" > "$OUT/wildcard.ips.txt" \
  || : > "$OUT/wildcard.ips.txt"

echo "[*] 3) Resolución DNS"
puredns resolve "$OUT/subs.all.txt" -r "$RESOLVERS" -w "$OUT/subs.resolved.txt" >/dev/null 2>&1 || true
dnsx -l "$OUT/subs.resolved.txt" -silent -a -aaaa -cname -resp | tee "$OUT/dns.enriched.txt" >/dev/null
cut -d ' ' -f1 "$OUT/dns.enriched.txt" | sort -u > "$OUT/hosts.live.txt"

echo "[*] 4) HTTP discovery"
httpx -l "$OUT/hosts.live.txt" -silent -follow-redirects -title -tech-detect -status-code -web-server -content-type \
  | tee "$OUT/httpx.live.txt" >/dev/null
cut -d ' ' -f1 "$OUT/httpx.live.txt" | sort -u > "$OUT/urls.live.txt"

echo "[*] 5) Takeover heurísticas"
grep -Ei "No such app|There isn't a GitHub Pages site here|Bucket.*does not exist|project not found|Domain isn't configured" \
  "$OUT/httpx.live.txt" > "$OUT/takeover.signals.txt" || true

echo "[*] 6) Nuclei"
[[ -s "$OUT/urls.live.txt" ]] && \
  nuclei -l "$OUT/urls.live.txt" -silent -severity low,medium,high,critical \
    -tags takeover,dns,misconfig,tech | tee "$OUT/nuclei.findings.txt" >/dev/null || true

echo "[*] Listo."
EOF
  chmod +x "$base/dns-pipeline.sh"

  echo "[✔] Proyecto creado en: $base"
  echo "[→] Ejecuta: cd $base && ./dns-pipeline.sh $domain"

  command -v tmux-recon >/dev/null 2>&1 && tmux-recon "recon-$domain" "$base"
}


# -------------------------
# mkproject_template
# -------------------------
mkproject_template() {
    [[ $# -lt 2 ]] && { echo "Uso: mkproject_template nombre plantilla"; echo "Plantillas: docencia, bugbounty, ctf"; return 1; }
    local proj="$1" tpl="$2"
    case "$tpl" in
        docencia)  mkdir -p "$proj"/{actividades,labs,scripts}; echo "# $proj" > "$proj/README.md" ;;
        bugbounty) mkdir -p "$proj"/{recon,enumeration,scans,exploits,pocs,wordlists,screenshots,notes,reports,loot}; echo "# $proj" > "$proj/README.md" ;;
        ctf)       mkdir -p "$proj"/{src,flags,writeups,notes}; echo "# $proj" > "$proj/README.md" ;;
        *)         echo "Plantilla desconocida: $tpl (docencia|bugbounty|ctf)"; return 2 ;;
    esac
    echo "Proyecto '$proj' creado con plantilla '$tpl'."
}


# -------------------------
# extra: descompresión automática
# -------------------------
extra() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;; *.tar.gz)  tar xzf "$1" ;; *.tar.xz)  tar xJf "$1" ;;
            *.tar)     tar xf  "$1" ;; *.tbz2)    tar xjf "$1" ;; *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip   "$1" ;; *.rar)      unrar x "$1" ;; *.7z)      7z x    "$1" ;;
            *.gz)      gunzip  "$1" ;; *.bz2)      bunzip2 "$1" ;;
            *) echo "'$1' no puede extraerse con extra()" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}


# -------------------------
# extractips
# -------------------------
extractips() { grep -Eroh '([0-9]{1,3}\.){3}[0-9]{1,3}' . | sort -u; }


# -------------------------
# quickvenv
# -------------------------
quickvenv() {
    python3 -m venv .venv && source .venv/bin/activate
    echo "Virtualenv .venv activado"
}


# -------------------------
# gotodir
# -------------------------
gotodir() {
    local dir
    dir=$(find . -type d -iname "*$1*" | head -n 1)
    [[ -d "$dir" ]] && cd "$dir" && echo "Entro en $dir" || echo "No encontrado"
}


# -------------------------
# updateall
# -------------------------
updateall() {
    update_system
    pip3 install --upgrade pip setuptools wheel
    command -v nvim >/dev/null 2>&1 && nvim --headless "+Lazy! sync" +qa
    echo "Todo actualizado."
}


# -------------------------
# subscan: delega en el script externo si existe, si no ejecuta inline
# -------------------------
subscan() {
    if command -v subscan >/dev/null 2>&1 && [[ "$(command -v subscan)" != "$0" ]]; then
        command subscan "$@"
        return
    fi

    [[ -z "${1:-}" ]] && { echo "Uso: subscan <dominio.com>"; return 1; }

    python3 - "$1" <<'PYCODE'
import sys, shutil, subprocess, json, signal, threading

def tty(): return sys.stdout.isatty()
def c(s, code): return f"\x1b[{code}m{s}\x1b[0m" if tty() else s
BOLD=lambda s:c(s,"1"); RED=lambda s:c(s,"31"); GRN=lambda s:c(s,"32"); YEL=lambda s:c(s,"33")

PORTS="80,443,8080,8443"
HTTPX_ARGS=['httpx','-silent','-follow-redirects','-status-code','-title','-ip','-ports',PORTS,'-json','-threads','200']

stop_event=threading.Event()
def handle_sigint(sig,frame): stop_event.set(); print(YEL("\n[!] Interrumpido"))
signal.signal(signal.SIGINT,handle_sigint)

def truncate(s,n=60): s=s or ""; return s if len(s)<=n else s[:n-1]+"…"
def run(cmd,input_text=None):
    p=subprocess.Popen(cmd,stdin=subprocess.PIPE if input_text else None,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
    out,err=p.communicate(input=input_text)
    return p.returncode,out,err

domain=sys.argv[1].strip()
missing=[x for x in ["subfinder","httpx"] if not shutil.which(x)]
if missing: print(RED("[x] Faltan: ")+", ".join(missing)); sys.exit(2)

print(BOLD(f"[*] Enumerando {domain}"))
_,subs,_=run(["subfinder","-silent","-d",domain,"-all","-recursive"])
subs="\n".join(sorted({s.strip().lower().lstrip("*.") for s in subs.splitlines() if s.strip()}))
if not subs.strip(): print(YEL("[!] Sin subdominios")); sys.exit(0)

print(BOLD("[*] Probando HTTP(S)"))
_,out,_=run(HTTPX_ARGS,input_text=subs)
rows=[]
for line in out.splitlines():
    try: rows.append(json.loads(line))
    except: continue

print(BOLD("\n"+"URL".ljust(52)+"SC".ljust(5)+"IP".ljust(18)+"TITLE"))
print("-"*100)
for r in rows:
    print(r.get("url","").ljust(52)+str(r.get("status_code","")).ljust(5)+str(r.get("host","") or r.get("ip","")).ljust(18)+truncate(r.get("title",""),42))
print(GRN(f"\n[+] {len(rows)} endpoints"))
PYCODE
}


# -------------------------
# ffufdirs / ffufparams
# -------------------------
ffufdirs() {
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  local wl="$WORDLISTS/fuzz4bounty/fuzz4bounty/dirsearch.txt"
  [[ ! -f "$wl" ]] && { echo "[!] Wordlist no encontrada: $wl"; return 1; }
  ffuf -u "https://${1:?Uso: ffufdirs <dominio>}/FUZZ" -w "$wl" -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}

ffufparams() {
  [[ -z "${WORDLISTS:-}" ]] && { echo "[!] \$WORDLISTS no definida"; return 1; }
  local wl="$WORDLISTS/fuzz4bounty/discovery/parameter.txt"
  [[ ! -f "$wl" ]] && { echo "[!] Wordlist no encontrada: $wl"; return 1; }
  ffuf -u "https://${1:?Uso: ffufparams <dominio>}/page.php?FUZZ=1" -w "$wl" -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}


# -------------------------
# subfinderall
# -------------------------
subfinderall() { command subfinder -d "$1" -all -t 100 -v -o "subs_${1}.txt"; }


# -------------------------
# ctfwriteup
# -------------------------
ctfwriteup() { mkdir -p "$1" && echo "# $1" > "$1/writeup.md" && nvim "$1/writeup.md"; }


# -------------------------
# aliases(): buscador de alias
# -------------------------
aliases() {
    [[ -z "${1:-}" ]] && alias | sort || alias | grep -i --color "$1"
}
