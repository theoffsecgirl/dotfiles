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

# ─── MOSTRAR INFO DEL SISTEMA BONITO ───
if command -v neofetch &> /dev/null; then
  sysinfo() {
    echo -e "\033[1;96m>>> Sistema:\033[0m"; neofetch
    echo -e "\033[1;96m>>> Espacio:\033[0m"; df -h /
    echo -e "\033[1;96m>>> Memoria:\033[0m"; free -h
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

# ─── NMAP EXPRESS ───
quickscan() {
  [[ -z "$1" ]] && echo "Uso: quickscan <IP>" && return 1
  nmap -T4 -F "$1"
}

# ─── LIMPIAR .pyc y __pycache__ ───
cleanpyc() {
  find . -type f -name "*.py[co]" -delete
  find . -type d -name "__pycache__" -delete
}

# ─── BASE64 ───
b64e() { base64 "$1"; }
b64d() { base64 -d "$1"; }

# ─── USER-AGENT ALEATORIO ───
randua() {
  curl -s https://useragentstring.com/pages/useragentstring.php?name=All | \
    grep -oP '(?<=<li><a href=".*?">).*?(?=</a>)' | shuf -n 1
}

# ─── RANDOM WORD ───
randword() {
  cat /usr/share/dict/words | shuf -n1
}

# ─── JS BEAUTIFY ───
jsbeauty() {
  js-beautify "$1" -o "$1.pretty.js"
}

# ─── EXTRACTORES DE PUERTOS DE NMAP ───
extractPorts(){
  ports=$(grep -oP '\d{1,5}/open' "$1" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
  ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$1" | sort -u | head -n 1)
  echo -e "\n[*] IP: $ip\n[*] Ports: $ports" | tee extractPorts.tmp
  echo $ports | tr -d '\n' | xclip -sel clip
}

# ─── FZF BONITO ───
fzf-lovely(){
  fzf --multi --preview '[[ $(file --mime {}) =~ binary ]] &&
    echo {} is a binary file ||
    (batcat --style=numbers --color=always {} ||
    highlight -O ansi -l {} ||
    cat {}) 2>/dev/null | head -500'
}

# ─── BORRADO SEGURO ───
rmk(){
  scrub -p dod "$1"
  shred -zun 10 -v "$1"
}

# ─── ESTRUCTURA PARA LABS (HTB, TryHackMe...) ───
mkhtb() {
  if [[ -z "$1" ]]; then
    echo -e "\033[1;91m[-] Uso: mkhtb <nombre-box>\033[0m"
    return 1
  fi
  mkdir -p "$1"/{recon,exploit,loot,www,notes}
  echo -e "\033[1;92m[+] Estructura para lab '$1' creada (HTB-style)\033[0m"
}

# ─── ESTRUCTURA PARA BUG BOUNTY / PENTEST ───
mkbb() {
  if [ -z "$1" ]; then
    echo "Uso: mkbb <nombre_target>"
    return 1
  fi

  base_dir=~/Bug\ Bounty/"$1"
  mkdir -p "$base_dir"/{burp,content,exploits,http,nmap,notes,scripts,recon,js,urls,screenshots}
  
  # Crear README base para anotaciones
  touch "$base_dir/notes/README.md"

  echo -e "\033[1;96m[+] Entorno completo creado para $1 en $base_dir\033[0m"
  cd "$base_dir" || return
}

# ─── ESTRUCTURA PARA RETOS CTF ───
mkctf() {
  if [ -z "$1" ]; then
    echo "Uso: mkctf <nombre_del_reto>"
    return 1
  fi

  base_dir=~/CTFs/"$1"
  mkdir -p "$base_dir"/{web,pwn,crypto,reversing,misc,forensics,notes,exploits,scripts,tools,screenshots,writeups}

  touch "$base_dir/notes/README.md"

  echo -e "\033[1;95m[+] Entorno CTF creado para $1 en $base_dir\033[0m"
  cd "$base_dir" || return
}

# ─── CONTAR LÍNEAS DE CÓDIGO EN PROYECTO ─────────────────────────────────────────
countlines() {
  find . -name '*.py' -o -name '*.sh' -o -name '*.js' -o -name '*.html' |
    xargs wc -l | sort -n
}

# ─── CREAR ARCHIVO TEMPORAL RÁPIDO ───────────────────────────────────────────────
tmpfile() {
  local file="/tmp/tmp_$(date +%s).txt"
  echo "Creado archivo temporal: $file"
  touch "$file"
  ${EDITOR:-nano} "$file"
}

# ─── ACTULIZAR SISTEMA ─────────────────────────────────────────────
update_system() {
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y
    elif command -v dnf &> /dev/null; then
        sudo dnf upgrade -y && sudo dnf autoremove -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm
    else
        echo "\033[1;91m[✘] Gestor de paquetes no soportado para el alias 'update'.\033[0m"
        return 1
    fi
}

# ─── CONVERTIR TEXTO A QR ────────────────────────────────────────────────────────
qr() {
  if [[ -z "$1" ]]; then
    echo "Uso: qr <texto>"
  else
    echo "$1" | qrencode -o - -t UTF8
  fi
}

# ─── TIMER VISUAL ────────────────────────────────────────────────────────────────
timer() {
  if [[ -z "$1" ]]; then
    echo "Uso: timer <segundos>"
  else
    echo -ne "\a"
    sleep "$1" && echo -e "\a⏰ ¡Tiempo terminado!"
  fi
}

# ─── BUSCAR ENTRE COMANDOS CON HISTORIA ──────────────────────────────────────────
hgrep() {
  history | grep "$1"
}
