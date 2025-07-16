#!/usr/bin/env sh

# ─── TheOffSecGirl Polybar Cuqui Launcher 💖 ──────────────────────

# Matar cualquier instancia anterior
killall -q polybar

# Esperar a que termine
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

# Iniciar barra principal
polybar main -c ~/.config/polybar/current.ini &

# Mensaje por si lanzas desde terminal
echo "🌸 Polybar pastel lanzada con exito, reina 🐞"
