# ─── AUTOCOMPLETADO MODERNO ───
# Use modern completion system
autoload -Uz compinit
compinit
 
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
 
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ─── EXTRAER ARCHIVOS ───
# Nota: Esta función usa múltiples herramientas. Se deja como está porque cada caso
# es independiente. Si no tienes 'unrar', solo fallará al extraer '.rar', pero
# seguirá funcionando para '.zip', '.tar.gz', etc.
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

# ─── RECORDATORIO TEMPORAL (Depende de notificaciones de escritorio) ───
if command -v notify-send &> /dev/null; then
  remindme() {
    (sleep "$1" && notify-send "⏰ Recordatorio" "$2") &
  }
fi

# ─── SERVIDOR RÁPIDO PARA POCS ───
pocserver() {
  echo "[*] Iniciando servidor en http://0.0.0.0:8080"
  mkdir -p ~/poc_logs
  cd ~/poc_logs || return
  python3 -m http.server 8080
}

# ─── CLONAR Y ENTRAR A REPO ───
gclone() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# ─── NMAP EXPRESS (Depende de nmap) ───
if command -v nmap &> /dev/null; then
  quickscan() {
    [[ -z "$1" ]] && echo "Uso: quickscan <IP>" && return 1
    nmap -T4 -F "$1"
  }
fi

# ─── LIMPIAR .pyc y __pycache__ ───
cleanpyc() {
  find . -type f -name "*.py[co]" -delete
  find . -type d -name "__pycache__" -delete
}

# ─── BASE64 ───
b64e() { base64 "$1"; }
b64d() { base64 -d "$1"; }

# ─── USER-AGENT ALEATORIO (Depende de curl) ───
if command -v curl &> /dev/null; then
  randua() {
    curl -s https://useragentstring.com/pages/useragentstring.php?name=All | \
      grep -oP '(?<=<li><a href=".*?">).*?(?=</a>)' | shuf -n 1
  }
fi

# ─── RANDOM WORD (Depende del diccionario del sistema) ───
if [ -f "/usr/share/dict/words" ]; then
  randword() {
    cat /usr/share/dict/words | shuf -n1
  }
fi

# ─── JS BEAUTIFY (Depende de js-beautify) ───
if command -v js-beautify &> /dev/null; then
  jsbeauty() {
    js-beautify "$1" -o "$1.pretty.js"
  }
fi

# ─── EXTRACTORES DE PUERTOS DE NMAP (Depende de xclip para el portapapeles) ───
if command -v xclip &> /dev/null; then
  extractPorts(){
    ports=$(grep -oP '\d{1,5}/open' "$1" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
    ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$1" | sort -u | head -n 1)
    echo -e "\n[*] IP: $ip\n[*] Ports: $ports" | tee extractPorts.tmp
    echo "$ports" | tr -d '\n' | xclip -sel clip
    echo "[+] Puertos copiados al portapapeles."
  }
fi

# ─── FZF BONITO (Depende de fzf y batcat/highlight) ───
if command -v fzf &> /dev/null; then
  fzf-lovely(){
    fzf --multi --preview '[[ $(file --mime {}) =~ binary ]] &&
      echo {} is a binary file ||
      (batcat --style=numbers --color=always {} ||
      highlight -O ansi -l {} ||
      cat {}) 2>/dev/null | head -500'
  }
fi

# ─── BORRADO SEGURO (Depende de scrub y shred) ───
if command -v scrub &> /dev/null && command -v shred &> /dev/null; then
  rmk(){
    scrub -p dod "$1"
    shred -zun 10 -v "$1"
  }
fi

# ─── ESTRUCTURA PARA LABS (HTB, TryHackMe...) ───

mkbox() {
  if [[ -z "$1" ]]; then
    echo -e "\033[1;91m[-] Uso: mkbox <nombre_box>\033[0m"
    return 1
  fi

  local name="$1"
  local base_dir=~/Machines/"$name"

  mkdir -p "$base_dir"/{recon,exploit,loot,www,notes}
  touch "$base_dir/notes/README.md"

  echo -e "\033[1;92m[+] Máquina creada: $name en $base_dir 💀\033[0m"
  cd "$base_dir" || return

  read "answer?💬 ¿Quieres añadir '$name' como target actual? (s/n): "
  if [[ "$answer" =~ ^[sS]$ ]]; then
    read "ip?🌐 IP o dominio (puedes dejarlo vacío): "
    settarget "$name" "$ip"
  fi
}


# ─── ESTRUCTURA PARA BUG BOUNTY / PENTEST ───

mkbb() {
  if [[ -z "$1" ]]; then
    echo "Uso: mkbb <nombre_target>"
    return 1
  fi

  local name="$1"
  local base_dir=~/Bug\ Bounty/"$name"

  mkdir -p "$base_dir"/{burp,content,exploits,http,nmap,notes,scripts,recon,js,urls,screenshots}
  touch "$base_dir/notes/README.md"

  echo -e "\033[1;96m[+] Target BB creado: $name en $base_dir 🎯\033[0m"
  cd "$base_dir" || return

  read "answer?💬 ¿Quieres añadir '$name' como target actual? (s/n): "
  if [[ "$answer" =~ ^[sS]$ ]]; then
    read "ip?🌐 IP o dominio (puedes dejarlo vacío): "
    settarget "$name" "$ip"
  fi
}

# ─── ESTRUCTURA PARA RETOS CTF ───

mkctf() {
  if [[ -z "$1" ]]; then
    echo "Uso: mkctf <nombre_del_reto>"
    return 1
  fi

  local name="$1"
  local base_dir=~/CTFs/"$name"

  mkdir -p "$base_dir"/{web,pwn,crypto,reversing,misc,forensics,notes,exploits,scripts,tools,screenshots,writeups}
  touch "$base_dir/notes/README.md"

  echo -e "\033[1;95m[+] Reto CTF creado: $name en $base_dir 🚩\033[0m"
  cd "$base_dir" || return

  read "answer?💬 ¿Quieres añadir '$name' como target actual? (s/n): "
  if [[ "$answer" =~ ^[sS]$ ]]; then
    read "ip?🌐 IP o dominio (puedes dejarlo vacío): "
    settarget "$name" "$ip"
  fi
}


# ─── CONTAR LÍNEAS DE CÓDIGO EN PROYECTO ───
countlines() {
  find . -name '*.py' -o -name '*.sh' -o -name '*.js' -o -name '*.html' |
    xargs wc -l | sort -n
}

# ─── CREAR ARCHIVO TEMPORAL RÁPIDO ───
tmpfile() {
  local file="/tmp/tmp_$(date +%s).txt"
  echo "Creado archivo temporal: $file"
  touch "$file"
  ${EDITOR:-nano} "$file"
}

# ─── MOSTRAR INFO DEL SISTEMA BONITO (Depende de neofetch) ───
if command -v neofetch &> /dev/null; then
  sysinfo() {
    echo -e "\033[1;96m>>> Sistema:\033[0m"; neofetch
    echo -e "\033[1;96m>>> Espacio:\033[0m"; df -h /
    echo -e "\033[1;96m>>> Memoria:\033[0m"; free -h
  }
fi

# ─── CONVERTIR TEXTO A QR (Depende de qrencode) ───
if command -v qrencode &> /dev/null; then
  qr() {
    if [[ -z "$1" ]]; then
      echo "Uso: qr <texto>"
    else
      echo "$1" | qrencode -o - -t UTF8
    fi
  }
fi

# ─── TIMER VISUAL ───
timer() {
  if [[ -z "$1" ]]; then
    echo "Uso: timer <segundos>"
  else
    echo -ne "\a"
    sleep "$1" && echo -e "\a⏰ ¡Tiempo terminado!"
  fi
}

# ─── BUSCAR ENTRE COMANDOS CON HISTORIA ───
hgrep() {
  history | grep "$1"
}
# ─── SUBDOMAIN TAKEOVER SCANNER (Bug Bounty) ───
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

    # 1. Enumeración silenciosa de subdominios
    echo -e "\033[1;94m[i] Ejecutando Subfinder...\033[0m"
    subfinder -d "${domain}" -silent > "${output_dir}/subfinder.txt"

    echo -e "\033[1;94m[i] Ejecutando Amass...\033[0m"
    amass enum -d "${domain}" -noalts -silent > "${output_dir}/amass.txt"

    echo -e "\033[1;94m[i] Ejecutando Assetfinder...\033[0m"
    assetfinder --subs-only "${domain}" > "${output_dir}/assetfinder.txt"

    # 2. Combinar y filtrar resultados
    cat "${output_dir}"/{subfinder,amass,assetfinder}.txt | \
        sort -u | \
        grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "${output_dir}/subdomains_final.txt"

    # 3. Verificar subdominios activos
    echo -e "\033[1;96m[+] Filtando subdominios activos (HTTP/HTTPS)\033[0m"
    httpx -l "${output_dir}/subdomains_final.txt" -silent -status-code -title -o "${output_dir}/active_subdomains.txt"

    # 4. Detección de takeovers
    echo -e "\033[1;96m[+] Buscando posibles subdomain takeovers...\033[0m"
    if command -v subjack &>/dev/null; then
        subjack -w "${output_dir}/active_subdomains.txt" -c ~/tools/subjack/fingerprints.json -o "${output_dir}/subjack_takeovers.txt"
    fi

    if command -v nuclei &>/dev/null; then
        nuclei -l "${output_dir}/active_subdomains.txt" -t ~/nuclei-templates/takeovers/ -o "${output_dir}/nuclei_takeovers.txt"
    fi

    # Resultados
    echo -e "\n\033[1;92m[+] Resultados guardados en: ${output_dir}\033[0m"
    echo -e "  \033[1;96m• Subdominios totales:\033[0m $(wc -l < "${output_dir}/subdomains_final.txt")"
    echo -e "  \033[1;96m• Subdominios activos:\033[0m $(wc -l < "${output_dir}/active_subdomains.txt")"
    echo -e "  \033[1;96m• Posibles takeovers:\033[0m"
    [[ -f "${output_dir}/subjack_takeovers.txt" ]] && echo -e "    - Subjack: \033[1;93m${output_dir}/subjack_takeovers.txt\033[0m"
    [[ -f "${output_dir}/nuclei_takeovers.txt" ]] && echo -e "    - Nuclei: \033[1;93m${output_dir}/nuclei_takeovers.txt\033[0m"
}




#  ------------------[ Bug Bounty Target Functions]----------------- #

function settarget() {
    local domain="$1"
    local ip="$2"
    local target_file="$HOME/.config/bspwm/scripts/target.txt"
    local log_file="$HOME/.config/bspwm/scripts/targets_history.txt"
    local target_dir="$HOME/targets/$domain"

    if [[ -z "$domain" ]]; then
        echo "❌ Uso: settarget dominio.com [IP]"
        return 1
    fi

    # Validar IP si está presente
    if [[ -n "$ip" && ! "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "⚠️ IP inválida, se ignorará: $ip"
        ip=""
    fi

    echo "$domain $ip" > "$target_file"
    mkdir -p "$target_dir"
    echo "$domain $ip - $(date +'%F %T')" >> "$log_file"

    echo "🎯 Target seteado: $domain ${ip:+($ip)}"
    echo "📁 Carpeta creada: $target_dir"
}

function cleartarget() {
    local target_file="$HOME/.config/bspwm/scripts/target.txt"
    local history_file="$HOME/.config/bspwm/scripts/targets_history.txt"

    if [[ -s "$target_file" ]]; then
        local datetime=$(date '+%Y-%m-%d %H:%M:%S')
        local current_target=$(cat "$target_file" | tr -d '\r')  # Limpiamos basura rara
        echo "[$datetime] $current_target" >> "$history_file"
        echo "📜 Target guardado en historial:"
        echo "   ➤ $current_target"
    else
        echo "⚠️ No hay target activo que limpiar."
    fi

    : > "$target_file"
    echo "🚫 Target limpiado"
}


function targetlog() {
    local log_file="$HOME/.config/bspwm/scripts/targets_history.txt"

    if [[ -f "$log_file" ]]; then
        echo "📚 Historial de targets:"
        cat "$log_file"
    else
        echo "🪹 Aún no hay historial de targets."
    fi
}


