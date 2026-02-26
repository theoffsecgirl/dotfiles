if command -v container >/dev/null 2>&1; then
  _CTR=container
  _RM_FLAG="--remove"
elif command -v docker >/dev/null 2>&1; then
  _CTR=docker
  _RM_FLAG="--rm"
else
  _CTR=""
fi

if [[ "${_CTR}" == "container" ]]; then
  alias container-ls='container list'
elif [[ "${_CTR}" == "docker" ]]; then
  alias container-ls='docker ps'
fi

alias container-shell-persist="${_CTR} run -it --name 0xETERNAL -v \$(pwd):/mnt -w /mnt --entrypoint=/bin/bash"
alias container-shell-ephemeral="${_CTR} run ${_RM_FLAG} -it -v \$(pwd):/mnt -w /mnt --entrypoint=/bin/bash"

alias kali-eternal='container-shell-persist kalilinux/kali-rolling:latest'
alias kali-ephemeral='container-shell-ephemeral kalilinux/kali-rolling:latest'
alias kali-web='container-shell-ephemeral -p 8080:80 kalilinux/kali-rolling:latest'
