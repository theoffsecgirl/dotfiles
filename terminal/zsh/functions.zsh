# ─── AUTOCOMPLETADO ───
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ─── EXTRAER ARCHIVOS ───
extract() {
  if [ -f "$1" ]; then
    echo -e "\033[1;96m[+] Extrayendo: $1\033[0m"
    case "$1" in
      *.tar.bz2) tar xvjf "$1" ;;
      *.tar.gz)  tar xvzf "$1" ;;
      *.tar.xz)  tar xvJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xvf "$1" ;;
      *.tbz2)    tar xvjf "$1" ;;
      *.tgz)     tar xvzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo -e "\033[1;91m[-] Formato no soportado: $1\033[0m" ;;
    esac
  else
    echo -e "\033[1;91m[-] Archivo no encontrado: $1\033[0m"
  fi
}

# ─── RECORDATORIO TEMPORAL ───
if command -v notify-send &> /dev/null; then
  remindme() {
    (sleep "$1" && notify-send "⏰ Recordatorio" "$2") &
  }
fi

# ─── SERVIDOR RÁPIDO ───
pocserver() {
  echo "[*] Iniciando servidor en http://0.0.0.0:8080"
  mkdir -p ~/poc_logs
  cd ~/poc_logs || return
  python3 -m http.server 8080
}

# ─── CLONAR Y ENTRAR ───
gclone() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# ─── SCAN RÁPIDO ───
if command -v nmap &> /dev/null; then
  quickscan() {
    [[ -z "$1" ]] && echo "Uso: quickscan <IP>" && return 1
    nmap -T4 -F "$1"
  }
fi

# ─── LIMPIAR PYC ───
cleanpyc() {
  find . -type f -name "*.py[co]" -delete
  find . -type d -name "__pycache__" -delete
}

# ─── BASE64 ───
b64e() { base64 "$1"; }
b64d() { base64 -d "$1"; }

# ─── USER-AGENT RANDOM ───
if command -v curl &> /dev/null; then
  randua() {
    curl -s https://useragentstring.com/pages/useragentstring.php?name=All | \
      grep -oP '(?<=<li><a href=".*?">).*?(?=</a>)' | shuf -n 1
  }
fi

# ─── PALABRA RANDOM ───
if [ -f "/usr/share/dict/words" ]; then
  randword() {
    shuf -n1 /usr/share/dict/words
  }
fi

# ─── JS BEAUTIFY ───
if command -v js-beautify &> /dev/null; then
  jsbeauty() {
    js-beautify "$1" -o "$1.pretty.js"
  }
fi

# ─── PUERTOS NMAP ───
if command -v xclip &> /dev/null; then
  extractPorts(){
    ports=$(grep -oP '\d{1,5}/open' "$1" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
    ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$1" | sort -u | head -n 1)
    echo -e "\n[*] IP: $ip\n[*] Ports: $ports" | tee extractPorts.tmp
    echo "$ports" | tr -d '\n' | xclip -sel clip
    echo "[+] Puertos copiados al portapapeles."
  }
fi

# ─── FZF BONITO ───
if command -v fzf &> /dev/null; then
  fzf-lovely(){
    fzf --multi --preview '[[ $(file --mime {}) =~ binary ]] &&
      echo {} is a binary file ||
      (batcat --style=numbers --color=always {} ||
      highlight -O ansi -l {} ||
      cat {}) 2>/dev/null | head -500'
  }
fi

# ─── BORRADO SEGURO ───
if command -v scrub &> /dev/null && command -v shred &> /dev/null; then
  rmk(){
    scrub -p dod "$1"
    shred -zun 10 -v "$1"
  }
fi

# ─── CREAR ESTRUCTURA MÁQUINAS ───
mkbox() {
  if [[ -z "$1" ]]; then
    echo -e "\033[1;91m[-] Uso: mkbox <nombre_box>\033[0m"
    return 1
  fi
  local name="$1"
  local base_dir=~/machines/"$name"
  mkdir -p "$base_dir"/{recon,exploit,loot,www,notes}
  touch "$base_dir/notes/README.md"
  echo -e "\033[1;92m[+] Máquina creada: $name en $base_dir 💀\033[0m"
  cd "$base_dir" || return
}

# ─── BUG BOUNTY ───
mkbb() {
  if [[ -z "$1" ]]; then
    echo "Uso: mkbb <nombre_target>"
    return 1
  fi
  local name="$1"
  local base_dir=~/bugbounty/"$name"
  mkdir -p "$base_dir"/{burp,content,exploits,http,nmap,notes,scripts,recon,js,urls,screenshots}
  touch "$base_dir/notes/README.md"
  echo -e "\033[1;96m[+] Target BB creado: $name en $base_dir 🎯\033[0m"
  cd "$base_dir" || return
}

# ─── CTF ───
mkctf() {
  if [[ -z "$1" ]]; then
    echo "Uso: mkctf <nombre_del_reto>"
    return 1
  fi
  local name="$1"
  local base_dir=~/ctf/"$name"
  mkdir -p "$base_dir"/{web,pwn,crypto,reversing,misc,forensics,notes,exploits,scripts,tools,screenshots,writeups}
  touch "$base_dir/notes/README.md"
  echo -e "\033[1;95m[+] Reto CTF creado: $name en $base_dir 🚩\033[0m"
  cd "$base_dir" || return
}

# ─── CONTAR LÍNEAS ───
countlines() {
  find . \( -name '*.py' -o -name '*.sh' -o -name '*.js' -o -name '*.html' \) | xargs wc -l | sort -n
}

# ─── ARCHIVO TEMPORAL ───
tmpfile() {
  local file="/tmp/tmp_$(date +%s).txt"
  echo "Creado archivo temporal: $file"
  touch "$file"
  ${EDITOR:-nano} "$file"
}

# ─── INFO DEL SISTEMA ───
if command -v neofetch &> /dev/null; then
  sysinfo() {
    echo -e "\033[1;96m>>> Sistema:\033[0m"; neofetch
    echo -e "\033[1;96m>>> Espacio:\033[0m"; df -h /
    echo -e "\033[1;96m>>> Memoria:\033[0m"; free -h
  }
fi

# ─── QR ───
if command -v qrencode &> /dev/null; then
  qr() {
    if [[ -z "$1" ]]; then
      echo "Uso: qr <texto>"
    else
      echo "$1" | qrencode -o - -t UTF8
    fi
  }
fi

# ─── TIMER ───
timer() {
  if [[ -z "$1" ]]; then
    echo "Uso: timer <segundos>"
  else
    echo -ne "\a"
    sleep "$1" && echo -e "\a⏰ ¡Tiempo terminado!"
  fi
}

# ─── HISTORIAL CON GREP ───
hgrep() {
  history | grep "$1"
}

# ─── SUBDOMAIN TAKEOVER SCANNER ───
subtake() {
  if [[ -z "$1" ]]; then
    echo -e "\033[1;91m[-] Uso: subtake <dominio>\033[0m"
    return 1
  fi

  local domain="$1"
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local output_dir="${HOME}/subdomain_takeover_${timestamp}"

  echo -e "\033[1;96m[+] Escaneando subdominios de: ${domain}\033[0m"
  mkdir -p "${output_dir}"

  echo -e "\033[1;94m[i] Ejecutando Subfinder...\033[0m"
  subfinder -d "${domain}" -silent > "${output_dir}/subfinder.txt"

  echo -e "\033[1;94m[i] Ejecutando Amass...\033[0m"
  amass enum -d "${domain}" -noalts -silent > "${output_dir}/amass.txt"

  echo -e "\033[1;94m[i] Ejecutando Assetfinder...\033[0m"
  assetfinder --subs-only "${domain}" > "${output_dir}/assetfinder.txt"

  cat "${output_dir}"/{subfinder,amass,assetfinder}.txt | \
      sort -u | \
      grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "${output_dir}/subdomains_final.txt"

  echo -e "\033[1;96m[+] Filtando subdominios activos (HTTP/HTTPS)\033[0m"
  httpx -l "${output_dir}/subdomains_final.txt" -silent -status-code -title -o "${output_dir}/active_subdomains.txt"

  echo -e "\033[1;96m[+] Buscando posibles subdomain takeovers...\033[0m"
  if command -v subjack &>/dev/null; then
    subjack -w "${output_dir}/active_subdomains.txt" -c ~/tools/subjack/fingerprints.json -o "${output_dir}/subjack_takeovers.txt"
  fi

  if command -v nuclei &>/dev/null; then
    nuclei -l "${output_dir}/active_subdomains.txt" -t ~/nuclei-templates/takeovers/ -o "${output_dir}/nuclei_takeovers.txt"
  fi

  echo -e "\n\033[1;92m[+] Resultados guardados en: ${output_dir}\033[0m"
  echo -e "  \033[1;96m• Subdominios totales:\033[0m $(wc -l < "${output_dir}/subdomains_final.txt")"
  echo -e "  \033[1;96m• Subdominios activos:\033[0m $(wc -l < "${output_dir}/active_subdomains.txt")"
  echo -e "  \033[1;96m• Posibles takeovers:\033[0m"
  [[ -f "${output_dir}/subjack_takeovers.txt" ]] && echo -e "    - Subjack: \033[1;93m${output_dir}/subjack_takeovers.txt\033[0m"
  [[ -f "${output_dir}/nuclei_takeovers.txt" ]] && echo -e "    - Nuclei: \033[1;93m${output_dir}/nuclei_takeovers.txt\033[0m"
}
