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
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instalar httpx (binario precompilado)
RUN wget -q https://github.com/projectdiscovery/httpx/releases/download/v1.6.8/httpx_1.6.8_linux_amd64.zip && \
    unzip -q httpx_1.6.8_linux_amd64.zip && \
    mv httpx /usr/local/bin/ && \
    chmod +x /usr/local/bin/httpx && \
    rm httpx_1.6.8_linux_amd64.zip README.md LICENSE.md

# Instalar ffuf (binario precompilado)
RUN wget -q https://github.com/ffuf/ffuf/releases/download/v2.1.0/ffuf_2.1.0_linux_amd64.tar.gz && \
    tar -xzf ffuf_2.1.0_linux_amd64.tar.gz && \
    mv ffuf /usr/local/bin/ && \
    chmod +x /usr/local/bin/ffuf && \
    rm ffuf_2.1.0_linux_amd64.tar.gz

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
