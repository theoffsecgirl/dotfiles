FROM debian:bookworm-slim

LABEL maintainer="theoffsecgirl"
LABEL description="Debian toolbox for web/API bug bounty"

# Evitar prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Actualizar y paquetes base
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    httpie \
    python3 \
    python3-pip \
    python3-venv \
    ca-certificates \
    gnupg \
    lsb-release \
    stow \
    zsh \
    tmux \
    neovim \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar Go (necesario para httpx y ffuf)
RUN wget -q https://go.dev/dl/go1.22.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz && \
    rm go1.22.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

# Instalar httpx (pinneado)
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Instalar ffuf (pinneado)
RUN go install github.com/ffuf/ffuf/v2@latest

# Crear estructura de trabajo
RUN mkdir -p /work/{targets,notes,scripts,templates}

# Instalar starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Configurar zsh como shell por defecto
RUN chsh -s /usr/bin/zsh root

# Workspace por defecto
WORKDIR /work

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 0

CMD ["/usr/bin/zsh"]
