FROM debian:bookworm-slim

LABEL maintainer="theoffsecgirl"
LABEL description="Debian toolbox for web/API bug bounty"

# Actualiza estos valores con: docker compose build --build-arg HTTPX_VERSION=x.y.z
ARG HTTPX_VERSION=1.6.10
ARG FFUF_VERSION=2.1.0
ARG SUBFINDER_VERSION=2.6.6
ARG NUCLEI_VERSION=3.2.6

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

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

# httpx
RUN wget -q "https://github.com/projectdiscovery/httpx/releases/download/v${HTTPX_VERSION}/httpx_${HTTPX_VERSION}_linux_amd64.zip" -O /tmp/httpx.zip && \
    unzip -q /tmp/httpx.zip -d /tmp/httpx && \
    mv /tmp/httpx/httpx /usr/local/bin/ && \
    chmod +x /usr/local/bin/httpx && \
    rm -rf /tmp/httpx.zip /tmp/httpx

# ffuf
RUN wget -q "https://github.com/ffuf/ffuf/releases/download/v${FFUF_VERSION}/ffuf_${FFUF_VERSION}_linux_amd64.tar.gz" -O /tmp/ffuf.tar.gz && \
    tar -xzf /tmp/ffuf.tar.gz -C /tmp && \
    mv /tmp/ffuf /usr/local/bin/ && \
    chmod +x /usr/local/bin/ffuf && \
    rm /tmp/ffuf.tar.gz

# subfinder
RUN wget -q "https://github.com/projectdiscovery/subfinder/releases/download/v${SUBFINDER_VERSION}/subfinder_${SUBFINDER_VERSION}_linux_amd64.zip" -O /tmp/subfinder.zip && \
    unzip -q /tmp/subfinder.zip -d /tmp/subfinder && \
    mv /tmp/subfinder/subfinder /usr/local/bin/ && \
    chmod +x /usr/local/bin/subfinder && \
    rm -rf /tmp/subfinder.zip /tmp/subfinder

# nuclei
RUN wget -q "https://github.com/projectdiscovery/nuclei/releases/download/v${NUCLEI_VERSION}/nuclei_${NUCLEI_VERSION}_linux_amd64.zip" -O /tmp/nuclei.zip && \
    unzip -q /tmp/nuclei.zip -d /tmp/nuclei && \
    mv /tmp/nuclei/nuclei /usr/local/bin/ && \
    chmod +x /usr/local/bin/nuclei && \
    rm -rf /tmp/nuclei.zip /tmp/nuclei

# anew (tomnomnom)
RUN wget -q "https://github.com/tomnomnom/anew/releases/download/v0.1.1/anew-linux-amd64-0.1.1.tgz" -O /tmp/anew.tgz && \
    tar -xzf /tmp/anew.tgz -C /usr/local/bin && \
    chmod +x /usr/local/bin/anew && \
    rm /tmp/anew.tgz

# starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Workspace
RUN mkdir -p /work/{targets,notes,scripts,templates}

# zsh por defecto
RUN chsh -s /usr/bin/zsh root

WORKDIR /work

# Healthcheck real: verifica que zsh existe y es ejecutable
HEALTHCHECK --interval=60s --timeout=5s --retries=2 \
    CMD [ -x /usr/bin/zsh ] || exit 1

CMD ["/usr/bin/zsh"]
