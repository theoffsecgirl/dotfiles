#!/bin/bash

TARGET_FILE="$HOME/.config/bspwm/scripts/target.txt"

# Iconos Nerd Font en vez de emojis (proporcionales en Polybar)
icon_target=""  # bandera
icon_none=""    # warning

if [[ -s "$TARGET_FILE" ]]; then
    read -r domain ip < "$TARGET_FILE"

    # Intentar obtener país (rápido y silencioso)
    country=$(curl -s --max-time 1 https://ipinfo.io/$ip/country | tr -d '\n')
    [[ -z "$country" ]] && country="VPN"

    # Mostrar resultado bonito
    echo "%{F#ffb3d6}%{T0}$icon_target %{F#ffffff}$domain %{F#aaaaaa}($ip · $country)%{F-}"
else
    echo "%{F#999999}%{T0}$icon_none No target%{F-}"
fi

