# Funciones de seguridad ofensiva, proyectos y utilidades



# Actualización de sistema según plataforma/distro

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


# mkproject: crear proyectos y subcarpetas
mkproject() {
  if [[ -z "$1" ]]; then
    echo "Uso: mkproject <nombre> [sub1 sub2 ...]"
    return 1
  fi

  local project_name="$1"
  shift

  mkdir -p "$project_name"
  for sub in "$@"; do
    mkdir -p "$project_name/$sub"
  done
}



# mkproject_template: crear proyectos con plantillas
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



# extra: descompresión automática según extensión
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



# extractips: extrae IPs únicas del dir actual
extractips() {
    grep -Eroh '([0-9]{1,3}\.){3}[0-9]{1,3}' . | sort -u
}


# quickvenv: crea y activa un venv en .venv
quickvenv() {
    python3 -m venv .venv && source .venv/bin/activate
    echo "Virtualenv .venv activado"
}


# gotodir: busca directorio y entra
gotodir() {
    dir=$(find . -type d -iname "*$1*" | head -n 1)
    if [[ -d "$dir" ]]; then
        cd "$dir"
        echo "Entro en $dir"
    else
        echo "No encontrado"
    fi
}


# updateall: actualiza sistema + pip + plugins Neovim
updateall() {
    update_system
    pip3 install --upgrade pip setuptools wheel

    if command -v nvim &>/dev/null; then
        nvim --headless "+Lazy! sync" +qa
    fi

    echo "Todo actualizado: sistema, pip y plugins de Neovim (si hay)."
}


# subscan: subfinder + httpx con output bonito
subscan() {
    if [ -z "$1" ]; then
        echo "Uso: subscan <dominio.com>"
        return 1
    fi

    python3 - "$1" <<'PYCODE'
# (el código python queda igual, no lo toco porque está perfecto)
PYCODE
}


# ffufdirs: fuzz de directorios
ffufdirs() {
    ffuf -u "https://$1/FUZZ" \
         -w "$WORDLISTS/fuzz4bounty/fuzz4bounty/dirsearch.txt" \
         -of md -o "ffuf_DIRS_$(date +%F_%H%M).md"
}


# ffufparams: fuzzing de parámetros
ffufparams() {
    ffuf -u "https://$1/page.php?FUZZ=1" \
         -w "$WORDLISTS/fuzz4bounty/discovery/parameter.txt" \
         -of md -o "ffuf_PARAMS_$(date +%F_%H%M).md"
}


# subfinderall: enumeración ampliada
subfinderall() {
    command subfinder -d "$1" -all -t 100 -v -o "subs_${1}.txt"
}


# ctfwriteup: carpeta + md + abre en nvim
ctfwriteup() {
    mkdir -p "$1" && echo "# $1" > "$1/writeup.md" && nvim "$1/writeup.md"
}


# aliases(): buscador de alias
aliases() {
    if [[ -z "$1" ]]; then
        alias | sort
    else
        alias | grep -i --color "$1"
    fi
}
