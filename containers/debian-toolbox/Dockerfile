FROM debian:bookworm-slim

LABEL maintainer="theoffsecgirl"
LABEL description="Debian toolbox for web/API bug bounty"

ARG FFUF_VERSION=2.1.0
ARG GO_VERSION=1.24.2
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"

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

RUN case "$TARGETARCH" in \
      "amd64") GO_ARCH="amd64" ;; \
      "arm64") GO_ARCH="arm64" ;; \
      *) echo "Arquitectura no soportada: $TARGETARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tgz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf /tmp/go.tgz && \
    rm -f /tmp/go.tgz

RUN case "$TARGETARCH" in \
      "amd64") FFUF_ARCH="amd64" ;; \
      "arm64") FFUF_ARCH="arm64" ;; \
      *) echo "Arquitectura no soportada para ffuf: $TARGETARCH" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/ffuf/ffuf/releases/download/v${FFUF_VERSION}/ffuf_${FFUF_VERSION}_linux_${FFUF_ARCH}.tar.gz" -O /tmp/ffuf.tar.gz && \
    tar -xzf /tmp/ffuf.tar.gz -C /tmp && \
    mv /tmp/ffuf /usr/local/bin/ && \
    chmod +x /usr/local/bin/ffuf && \
    rm -f /tmp/ffuf.tar.gz

RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

RUN mkdir -p /work/{targets,notes,scripts,templates}

RUN chsh -s /usr/bin/zsh root

WORKDIR /work

HEALTHCHECK --interval=60s --timeout=5s --retries=2 \
    CMD [ -x /usr/bin/zsh ] || exit 1

CMD ["/root/.dotfiles/containers/debian-toolbox/bootstrap-zsh.sh"]
