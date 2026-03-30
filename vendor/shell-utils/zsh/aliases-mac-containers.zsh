# --------------------------------------
# Alias/funciones para containers en macOS (Apple containerd)
# Se usan funciones en vez de aliases para poder pasar la imagen como $1
# --------------------------------------

# Listar contenedores
alias container-ls='container list'

# Shell persistente — recibe imagen como argumento
# Uso: container-shell-persist kalilinux/kali-rolling:latest
container-shell-persist() {
  local image="${1:?Uso: container-shell-persist <imagen>}"
  container run \
    --interactive \
    --tty \
    --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --workdir /mnt \
    --name "0xETERNAL" \
    "$image"
}

# Shell efímera — recibe imagen como argumento
# Uso: container-shell-ephemeral kalilinux/kali-rolling:latest
container-shell-ephemeral() {
  local image="${1:?Uso: container-shell-ephemeral <imagen>}"
  container run \
    --remove \
    --interactive \
    --tty \
    --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --workdir /mnt \
    --name "0xEPHEMERAL-$(date +%s)" \
    "$image"
}

# Kali persistente
alias kali-eternal='container-shell-persist kalilinux/kali-rolling:latest'

# Kali efímera
alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'

# Kali con puerto web expuesto (para labs rápidos)
kali-web() {
  container run \
    --remove \
    --interactive \
    --tty \
    --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --workdir /mnt \
    --name "0xEPHEMERAL-$(date +%s)" \
    -p 8080:80 \
    kalilinux/kali-rolling:latest
}
