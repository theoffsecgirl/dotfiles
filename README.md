
## 🎵 Módulo de Spotify

    *Función:* Muestra la canción actual que se está reproduciendo en Spotify.
    *Acciones:*

  - 🔊 Scroll ↑/↓: Sube o baja el volumen.
  - 🎵 Click izquierdo: Pausa o reanuda.

    *Extra:* Si el título es muy largo, se desliza automáticamente estilo marquee.


## 🎯 Módulo de Target

    *Función:* Muestra el dominio/IP del objetivo actual de pentest o bug bounty.
    *Comandos disponibles:*

  - settarget dominio.com 1.2.3.4: establece el target y crea carpeta.
  - cleartarget: limpia el target y lo guarda en historial.
  - targetlog: muestra historial.

    *Ruta de almacenamiento:* ~/.config/bspwm/scripts/target.txt y ~/targets/.


## 🔐 Módulo VPN

    *Función:* Muestra si la VPN está activa (detecta proton0).
    *Estado:*

  - ✅ Conectada: muestra bandera del país.
  - ❌ Desconectada: aparece “Disconnected”.


## 📡 Módulo de Red

    *Función:* Muestra tu IP local si estás conectada.
    *Interfaces soportadas:* wlan0, wlan1 y detecta automáticamente cuál está activa.


## 🌟 Módulo de Motivación

    *Función:* Muestra frases motivadoras random.
    *Cambio:* Cada 10 minutos (por defecto).
    *Estilo:* Letras rosas,.


---

## ⚙️ Detalles Técnicos

Todos los scripts están en ~/.config/bspwm/scripts/ y se invocan desde Polybar mediante módulos de tipo custom/script.

La estética está optimizada con:

    Tonos pastel 🌸
    Fuente principal: Iosevka Nerd Font
    Fuente emojis: JoyPixels mini


---

    💡 *Pro tip:* para ver todos los atajos de teclado de bspwm, kitty y fzf, abre la [Guía de Atajos TheOffSecGirl](./Guia_Atajos_TheOffSecGirl.pdf) 📘
