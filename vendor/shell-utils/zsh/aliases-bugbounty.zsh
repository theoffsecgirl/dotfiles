# =========================
# Bug Bounty helpers
# =========================

# Mostrar aliases de forma legible
showaliases() {
  alias | sed 's/^alias //' | column -t -s'=' | less
}

# -------------------------
# Docker helpers
# -------------------------

drm() {
  local ids
  ids="$(docker ps -aq)"
  [[ -z "$ids" ]] && { echo "No hay contenedores."; return 0; }
  docker rm $ids
}

dstopall() {
  local ids
  ids="$(docker ps -aq)"
  [[ -z "$ids" ]] && { echo "No hay contenedores."; return 0; }
  docker stop $ids
}

# -------------------------
# Credenciales / secretos
# -------------------------

findcreds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|credential" "$target"
}

creds() {
  local target="${1:-.}"
  grep -Ri --color=always -E "pass|secret|token|key" "$target"
}

# -------------------------
# Reporting
# -------------------------

mdreport() {
  local ts fname
  ts="$(date +'%F %T')"
  fname="README_$(date +%F_%H%M).md"
  printf "# Informe (%s)\n" "$ts" > "$fname"
  echo "Creado: $fname"
}

# -------------------------
# File hunting
# -------------------------

bigfiles() {
  local target="${1:-.}"
  find "$target" -type f -size +100M -exec ls -lh {} \; 2>/dev/null \
    | awk '{print $9 ": " $5}'
}

# -------------------------
# Containers (wrappers)
# -------------------------

container-shell-persist() {
  container run --interactive --tty --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --name "OxETERNAL" \
    --workdir /mnt
}

container-shell-ephemeral() {
  container run --remove --interactive --tty --entrypoint=/bin/bash \
    --volume "$(pwd):/mnt" \
    --name "0xEPHEMERAL" \
    --workdir /mnt
}
