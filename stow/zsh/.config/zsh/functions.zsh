#!/usr/bin/env zsh

case "$(uname)" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      PLATFORM="other" ;;
esac

# ─── AUTOCOMPLETADO ───────────────────────────────────────────────────────
autoload -Uz compinit
compinit
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' menu select=2

if [[ "$PLATFORM" == "linux" ]] && command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
elif [[ "$PLATFORM" == "macos" ]]; then
    export LSCOLORS=GxFxCxDxBxegedabagaced
    zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}
fi

# ─── EXTRAER ARCHIVOS ─────────────────────────────────────────────────────
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2) tar xvjf "$1" ;;
            *.tar.gz) tar xvzf "$1" ;;
            *.tar.xz) tar xvJf "$1" ;;
            *.bz2) bunzip2 "$1" ;;
            *.rar) unrar x "$1" ;;
            *.gz) gunzip "$1" ;;
            *.tar) tar xvf "$1" ;;
            *.tbz2) tar xvjf "$1" ;;
            *.tgz) tar xvzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.Z) uncompress "$1" ;;
            *.7z) 7z x "$1" ;;
            *) echo "Formato no soportado: $1" ;;
        esac
    else
        echo "Archivo no encontrado: $1"
    fi
}

# ─── RECORDATORIOS ────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "linux" ]] && command -v notify-send &> /dev/null; then
    remindme() { (sleep "$1" && notify-send "Recordatorio" "$2") & }
elif [[ "$PLATFORM" == "macos" ]]; then
    remindme() { (sleep "$1" && osascript -e "display notification \"$2\" with title \"Recordatorio\"") & }
fi

# ─── PALABRA ALEATORIA ────────────────────────────────────────────────────
if [[ -f "/usr/share/dict/words" ]]; then
    if [[ "$PLATFORM" == "macos" ]]; then
        randword() { gshuf -n1 /usr/share/dict/words 2>/dev/null || shuf -n1 /usr/share/dict/words; }
    else
        randword() { shuf -n1 /usr/share/dict/words; }
    fi
fi

# ─── PUERTOS DE NMAP ──────────────────────────────────────────────────────
if [[ "$PLATFORM" == "linux" ]]; then
    extractPorts() {
        ports=$(grep -oP '\d{1,5}/open' "$1" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
        ip=$(grep -oP '\d{1,3}(\.\d{1,3}){3}' "$1" | sort -u | head -n 1)
        echo -e "\n[*] IP: $ip\n[*] Ports: $ports" | tee extractPorts.tmp
        echo "$ports" | tr -d '\n' | xclip -sel clip
        echo "[+] Puertos copiados al portapapeles."
    }
elif [[ "$PLATFORM" == "macos" ]]; then
    extractPorts() {
        ports=$(grep -oE '[0-9]{1,5}/open' "$1" | awk -F/ '{print $1}' | xargs | tr ' ' ',')
        ip=$(grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' "$1" | sort -u | head -n 1)
        echo -e "\n[*] IP: $ip\n[*] Ports: $ports" | tee extractPorts.tmp
        echo "$ports" | tr -d '\n' | pbcopy
        echo "[+] Puertos copiados al portapapeles."
    }
fi
