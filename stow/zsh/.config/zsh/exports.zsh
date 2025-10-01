#!/usr/bin/env zsh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

case "$(uname)" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      PLATFORM="other" ;;
esac

# ─── WORDLISTS ────────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "linux" && -d "/usr/share/wordlists" ]]; then
    export WORDLISTS="/usr/share/wordlists"
elif [[ "$PLATFORM" == "macos" ]]; then
    if [[ -d "/opt/homebrew/share/wordlists" ]]; then
        export WORDLISTS="/opt/homebrew/share/wordlists"
    elif [[ -d "$HOME/wordlists" ]]; then
        export WORDLISTS="$HOME/wordlists"
    fi
fi

# ─── PATHS ────────────────────────────────────────────────────────────────
export PATH="$PATH:$HOME/.local/bin"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

if [[ "$PLATFORM" == "macos" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_ANALYTICS=1
    export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
elif [[ "$PLATFORM" == "linux" ]]; then
    export PATH="/usr/local/go/bin:$PATH"
fi

# ─── EDITOR ──────────────────────────────────────────────────────────────
if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim"
elif command -v vim &> /dev/null; then
    export EDITOR="vim"
    export VISUAL="vim"
fi

# ─── HISTORIAL ───────────────────────────────────────────────────────────
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"

# ─── BUG BOUNTY ──────────────────────────────────────────────────────────
if [[ -d "$HOME/bugbounty" ]]; then
    export BUGBOUNTY_HOME="$HOME/bugbounty"
    export PATH="$BUGBOUNTY_HOME:$PATH"
fi

