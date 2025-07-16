#!/bin/bash

frases=(
    "Hackea con cariño"
    "Seguridad con estilo"
    "Sé cuqui pero letal"
    "Tú puedes, hacker bella"
    "Mentalidad de 0day"
    "Explota bugs, no corazones"
    "Bug bounty con flow"
    "Paz interior, shell exterior"
    "Nmap y brillitos"
    "Hackea con amor y VPN"
    "Explota vulnerabilidades, no corazones"
    "Sudo make me proud"
    "Mentalidad de 0day, flow kawaii"
    "RTFM pero con glitter"
    "Pwn y paz interior"
    "Más burp, menos drama"
    "Vulnerable, como yo sin café"
    "Hack the planet y tus inseguridades"
    "Shell elegante, mente brillante"
    "Tu recon es arte"
    "Pwn princess en acción"
    "El bug bounty es mi cardio"
    "La vida es mejor con nmap"
    "Respira hondo y fuzzéalo"
    "Burp. Repite. Cobra."
    "Pwnéame esta"
    "Escaneando tus sentimientos"
    "XSS pero cute"
    "Cazadora de CVEs y sueños"
    "Ping a tu autoestima: alive"
    "Tú + DNS = destino"
    "Reconquista y recon"
    "Mi payload también lleva purpurina"
    "Explotando bugs y estereotipos"
    "Burps & dreams"
    "Estás a un recon de la gloria"
    "Que no te auditen el corazón"
    "Ctrl+C tus miedos, Ctrl+V tu poder"
    "El XSS no llora, brilla"
    "Buffer overflow de autoestima"
    "Conexión segura y autoestima alta"
    "Cazadora de flags y miradas"
    "Exploitate a ti misma primero"
    "La vida es un CTF continuo"
    "Escalada de privilegios emocional"
    "Estoy en tu red y en tu mente"
    "Don’t touch my shell, honey"
    "CVE: Cutest Vulnerability Ever"
    "Siempre lista para un nmap -A"
    "Un bug al día mantiene el drama lejos"
    "Nunca subestimes a una hacker con eyeliner"
)

tmpfile="/tmp/polybar-motivacion-cache"
interval=600  # 10 minutos

# Si se pasa --force, forzamos nueva frase
if [[ "$1" == "--force" ]]; then
    frase="${frases[RANDOM % ${#frases[@]}]}"
    echo "%{F#ffb3d6}$frase%{F-}" > "$tmpfile"
    exit 0
fi

# Si ya existe y es reciente, mostrar la guardada
if [[ -f "$tmpfile" ]]; then
    lastmod=$(stat -c %Y "$tmpfile")
    now=$(date +%s)
    if (( now - lastmod < interval )); then
        cat "$tmpfile"
        exit 0
    fi
fi

# Elegir nueva frase si no hay o ha pasado el tiempo
frase="${frases[RANDOM % ${#frases[@]}]}"
echo "%{F#ffb3d6}$frase%{F-}" > "$tmpfile"
cat "$tmpfile"
