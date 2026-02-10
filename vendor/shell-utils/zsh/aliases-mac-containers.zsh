# --------------------------------------
# Alias para containers en macOS (Apple containerd)
# Sin network porque la red por defecto ya funciona.
# --------------------------------------

# Listar contenedores
alias container-ls='container list'

# Shell persistente (misma instancia, no se borra)
alias container-shell-persist='container run \
    --interactive \
    --tty \
    --entrypoint=/bin/bash \
    --volume $(pwd):/mnt \
    --workdir /mnt \
    --name "0xETERNAL"'

# Shell efímera (se borra al salir, nombre aleatorio)
alias container-shell-ephemeral='container run \
    --remove \
    --interactive \
    --tty \
    --entrypoint=/bin/bash \
    --volume $(pwd):/mnt \
    --workdir /mnt \
    --name "0xEPHEMERAL-$(date +%s)"'

# Kali persistente
alias kali-eternal='container-shell-persist kalilinux/kali-rolling:latest'

# Kali efímera
alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'

# Kali con puerto web expuesto (para labs rápidos)
alias kali-web='container-shell-ephemeral -p 8080:80 kalilinux/kali-rolling:latest'
