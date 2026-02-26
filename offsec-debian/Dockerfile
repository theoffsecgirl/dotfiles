FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  zsh tmux neovim git curl jq \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/zsh offsec
USER offsec
WORKDIR /work

CMD ["zsh","-l"]
