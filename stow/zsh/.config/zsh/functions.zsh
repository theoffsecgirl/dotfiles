#!/usr/bin/env zsh

# --------------------------------------
# Detección de plataforma (macOS, Linux, otro)
# --------------------------------------
case "$(uname)" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      PLATFORM="other" ;;
esac

# --------------------------------------
# Gestión rápida del historial de comandos de zsh
# --------------------------------------
alias clrhist="echo '' > ~/.zsh_history"
alias rmhist="rm ~/.zsh_history"

# --------------------------------------
# Variables y aliases para wordlists según plataforma
# --------------------------------------
if [[ "$PLATFORM" == "linux" && -d "/usr/share/wordlists" ]]; then
    export WORDLISTS="/usr/share/wordlists"
    alias wordlists='cd $WORDLISTS'
    alias lsw='ls -la $WORDLISTS'
    alias fword='find $WORDLISTS -type f -iname "*$1*"'
elif [[ "$PLATFORM" == "macos" ]]; then
    if [[ -d "/opt/homebrew/share/wordlists" ]]; then
        export WORDLISTS="/opt/homebrew/share/wordlists"
    elif [[ -d "$HOME/wordlists" ]]; then
        export WORDLISTS="$HOME/wordlists"
    fi
    [[ -n "$WORDLISTS" ]] && alias wordlists='cd $WORDLISTS'
fi

# --------------------------------------
# Alias para cat mejorado (batcat o bat)
# --------------------------------------
if command -v batcat &> /dev/null; then
    alias cat='batcat --paging=always --decorations=always'
elif command -v bat &> /dev/null; then
    alias cat='bat --paging=always --decorations=always'
fi

# Alias para tener siempre acceso al cat original
if [[ "$PLATFORM" == "macos" ]]; then
    alias rcat='/bin/cat'
else
    alias rcat='/usr/bin/cat'
fi

# --------------------------------------
# Alias de listado de archivos mejorado (lsd, eza o ls)
# --------------------------------------
if command -v lsd &> /dev/null; then
    alias ll='lsd -la --group-dirs=first'
    alias l='lsd'
    alias cl='clear && lsd'
elif command -v eza &> /dev/null; then
    alias ll='eza -la --group-directories-first'
    alias l='eza'
    alias cl='clear && eza'
else
    if [[ "$PLATFORM" == "linux" ]]; then
        alias ll='ls -alh --group-directories-first --color=auto'
        alias l='ls --color=auto'
        alias cl='clear && ls --color=auto'
    else
        alias ll='ls -alh'
        alias l='ls -G'
        alias cl='clear && ls -G'
    fi
fi

# --------------------------------------
# Navegación rápida y utilidades esenciales de terminal
# --------------------------------------
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias mkdir='mkdir -p'
alias rmrf='rm -rf'
alias mv='mv -i'
alias chmodx='chmod +x'

# --------------------------------------
# Alias y herramientas para logs del sistema según plataforma
# --------------------------------------
if [[ "$PLATFORM" == "linux" ]]; then
    alias watchlog='tail -f /var/log/syslog'
    alias logerror='grep -i error /var/log/syslog'
    alias logauth='batcat /var/log/auth.log 2>/dev/null || cat /var/log/auth.log'
    alias logsize='du -sh /var/log/* | sort -h'
    alias viewlog='batcat /var/log/syslog 2>/dev/null || cat /var/log/syslog'
elif [[ "$PLATFORM" == "macos" ]]; then
    alias watchlog='tail -f /var/log/system.log'
    alias logerror='grep -i error /var/log/system.log'
    alias logauth='log show --predicate "eventMessage contains \"authentication\"" --last 1h'
    alias logsize='du -sh /var/log/* | sort -h'
    alias viewlog='log show --last 1h'
fi

# --------------------------------------
# Alias para sniffing/red y utilidades de red por plataforma
# --------------------------------------
if [[ "$PLATFORM" == "linux" ]]; then
    alias sniff='tcpdump -i eth0 -nn -s0 -w capture.pcap'
    alias ifconfig='ip a'
elif [[ "$PLATFORM" == "macos" ]]; then
    alias sniff='sudo tcpdump -i en0 -nn -s0 -w capture.pcap'
fi

# --------------------------------------
# Otras utilidades útiles y comandos rápidos de sistema/red
# --------------------------------------
alias myip='curl ifconfig.me'
alias pingfast='ping -c 5 -i 0.2 google.com'
alias dnslookup='dig +short'

# Mostrar puertos abiertos según sistema
if [[ "$PLATFORM" == "linux" ]]; then
    alias ports='ss -tulanp'
else
    alias ports='netstat -anv'
fi

# Servidor web Python rápido en la carpeta actual
alias httproot='python3 -m http.server 8080'

# --------------------------------------
# Función para actualizar el sistema según la distro/OS
# --------------------------------------
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

# --------------------------------------
# Espacio de disco, memoria, y otras consultasy limpieza
# --------------------------------------
if [[ "$PLATFORM" == "linux" ]]; then
    alias diskspace='df -h --total | grep total'
    alias mem='free -h --si'
else
    alias diskspace='df -h | tail -1'
    alias mem='top -l 1 -s 0 | grep PhysMem'
fi

alias freespace='du -sh * | sort -h'
alias cpuload="uptime | awk '{print \"Carga:\", \$9, \$10, \$11}'"
alias findtxt='find . -type f -name "*.txt"'
alias grepip="grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'"
alias greppass="grep -i 'password'"
alias untar='tar -xvf'
alias unzipdir='unzip -d ./extracted/'
alias wgetr="wget --continue"
alias dps="docker ps"
alias di="docker images"
alias drm="docker rm \$(docker ps -aq)"

# --------------------------------------
# Alias exclusivos para macOS
# --------------------------------------
if [[ "$PLATFORM" == "macos" ]]; then
    alias finder='open .'
    alias brewup='brew update && brew upgrade'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
    alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
    alias mfconsole='/opt/metasploit-framework/bin/msfconsole'
fi

# --------------------------------------
# FUNCION MKPROJECT 
# Crea proyecto y subcarpetas a tu elección
# Uso: mkproject nombre_proyecto [subcarpeta1 subcarpeta2 ...]
# Ejemplo: mkproject pentest src docs reportes
# --------------------------------------
mkproject() {
    # Comprobar si se ha dado el nombre del proyecto
    if [[ -z "$1" ]]; then
        echo "Tienes que indicar el nombre del proyecto!"
        return 1
    fi
    project_name="$1"   # Guardar nombre de proyecto
    shift               # Eliminar nombre de proyecto del listado de argumentos

    # Si no hay subcarpetas, solo crea la carpeta principal
    if [[ "$#" -eq 0 ]]; then
        mkdir -p "$project_name"
        echo "Proyecto '$project_name' creado (sin subcarpetas)."
    else
        # Crear cada subcarpeta introducida
        for sub in "$@"; do
            mkdir -p "$project_name/$sub"
        done
        echo "Proyecto '$project_name' creado con subcarpetas: $*"
    fi
}
alias mkproject='mkproject'

# --------------------------------------
# Función: mkproject_template
# Inicializa proyectos con estructura y archivos base según plantilla
# Uso: mkproject_template nombre_proyecto plantilla
# Plantillas disponibles: docencia, bugbounty, ctf
# --------------------------------------
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
            touch "$proj/README.md"
            echo "# Docencia: $proj" > "$proj/README.md"
            echo "- Actividades: ejercicios y tareas" >> "$proj/README.md"
            echo "- Labs: prácticas guiadas" >> "$proj/README.md"
            echo "- Scripts: utilidades y herramientas" >> "$proj/README.md"
            ;;
        bugbounty)
            mkdir -p "$proj"/{recon,enumeration,scans,exploits,pocs,wordlists,screenshots,notes,reports,loot}
            touch "$proj/README.md"
            echo "# Bug Bounty: $proj" > "$proj/README.md"
            echo "- Recon: subdominios/hosts" >> "$proj/README.md"
            echo "- Enumeration: info detallada" >> "$proj/README.md"
            echo "- Scans: nmap, nuclei, ffuf…" >> "$proj/README.md"
            echo "- Exploits/Pocs: scripts o PoCs" >> "$proj/README.md"
            echo "- Wordlists: listas específicas" >> "$proj/README.md"
            echo "- Screenshots: pruebas visuales" >> "$proj/README.md"
            echo "- Notes: findings y procesos" >> "$proj/README.md"
            echo "- Reports: borradores y entregables" >> "$proj/README.md"
            echo "- Loot: credenciales, datos…" >> "$proj/README.md"
            ;;
        ctf)
            mkdir -p "$proj"/{src,flags,writeups,notes}
            touch "$proj/README.md"
            echo "# CTF: $proj" > "$proj/README.md"
            echo "- src: exploits/scripts" >> "$proj/README.md"
            echo "- flags: resultados CTF" >> "$proj/README.md"
            echo "- writeups: soluciones" >> "$proj/README.md"
            echo "- notes: apuntes rápidos" >> "$proj/README.md"
            ;;
        *)
            echo "Plantilla desconocida: $tpl"
            echo "Opciones válidas: docencia, bugbounty, ctf"
            return 2
            ;;
    esac
    echo "Proyecto '$proj' creado con plantilla '$tpl'."
}


# --------------------------------------
# Función: extra
# Descomprime automáticamente archivos según extensión (.zip, .tar.gz, .7z, ...)
# Uso: extra archivo_comprimido
# --------------------------------------
extra() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.tar.xz)    tar xJf "$1"   ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.rar)       unrar x "$1"   ;;
            *.7z)        7z x "$1"      ;;
            *.gz)        gunzip "$1"    ;;
            *.bz2)       bunzip2 "$1"   ;;
            *)           echo "'$1' no puede ser extraído vía extra()" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# --------------------------------------
# Función: extractips
# Extrae todas las IPs únicas de todos los archivos de texto/dump en el directorio actual
# Uso: extractips > ips.txt
# --------------------------------------
extractips() {
    grep -Eroh '([0-9]{1,3}\.){3}[0-9]{1,3}' . | sort -u
}

# --------------------------------------
# Función: quickvenv
# Crea y activa un entorno Python virtualenv rápidamente en la carpeta actual
# Uso: quickvenv
# --------------------------------------
quickvenv() {
    python3 -m venv .venv && source .venv/bin/activate
    echo "Virtualenv .venv activado"
}

# --------------------------------------
# Función: gotodir
# Busca recursivamente el primer directorio coincidente y lo abre
# Uso: gotodir nombre_parcial
# --------------------------------------
gotodir() {
    dir=$(find . -type d -iname "*$1*" | head -n 1)
    if [[ -d "$dir" ]]; then
        cd "$dir"
        echo "Entro en $dir"
    else
        echo "No encontrado"
    fi
}

# --------------------------------------
# Función: updateall
# Actualiza sistema, pip, y herramientas clave (personalízalo a tus binarios favoritos)
# Uso: updateall
# --------------------------------------
updateall() {
    update_system
    pip3 install --upgrade pip setuptools wheel
    if command -v nvim &>/dev/null; then nvim --headless "+Lazy! sync" +qa; fi
    echo "Todo actualizado: sistema, pip y plugins de Neovim (si hay)."
}

# --- FUNCIONES HACK/CTF AVANZADAS ---

# 1. FFUF directo sobre un host (argumento: dominio/target), resultados limpios
ffufdirs() {
  # Uso: ffufdirs target.com
  ffuf -u "https://$1/FUZZ" -w "$WORDLISTS/dirbuster/directory-list-2.3-medium.txt" -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}

# 2. FFUF sobre parámetros (argumento: dominio)
ffufparams() {
  # Uso: ffufparams target.com
  ffuf -u "https://$1/page.php?FUZZ=1" -w "$WORDLISTS/params.txt" -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}

# 3. Subdomain discovery optimizado para bug bounty (argumento: dominio)
subfinderall() {
  # Uso: subfinderall dominio.com
  command subfinder -d "$1" -all -t 100 -v -o "subs_${1}.txt"
}

# 4. Crear carpeta y archivo .md para writeup de CTF (argumento: nombre_reto)
ctfwriteup() {
  # Uso: ctfwriteup nombre_reto
  mkdir -p "$1" && echo "# $1" > "$1/writeup.md" && nvim "$1/writeup.md"
}

