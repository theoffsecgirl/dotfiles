<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)

**Personal dotfiles**
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇪🇸 [Versión en español](README.es.md)

</div>

## What this is

A macOS-first, terminal-centric dotfiles setup managed with [GNU Stow](https://www.gnu.org/software/stow/) and a `Makefile`. It covers shell configuration (zsh), Neovim, tmux, Ghostty and git.

The bug bounty / pentesting pipeline (recon scripts, containers, hunting workspace template) used to live in this repo. It has since moved, with its full commit history, to [theoffsecgirl/bugbounty-toolkit](https://github.com/theoffsecgirl/bugbounty-toolkit) — a separate, private repo. This repo no longer contains or depends on it.

## Install

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
exec zsh
```

`make install` runs `stow -t $HOME runcom config bin` and `brew bundle --file=install/Brewfile`.

Preview the Stow changes without applying them:

```bash
stow -n -v -t "$HOME" runcom config bin
```

On a brand-new Mac, `make macos` bootstraps Homebrew itself and then delegates to `make install`:

```bash
make macos
```

Machine-specific overrides belong in `~/.config/zsh/local.zsh`, which is not versioned.

## Makefile targets

```bash
make help     # lists all targets
make install  # stow runcom/config/bin + brew bundle
make macos    # bootstrap a fresh macOS machine (Homebrew + make install)
make test     # run the bats test suite
make update   # brew update/upgrade + re-stow
make clean    # remove the symlinks created by stow
make edit     # open the repo in $EDITOR
```

## Useful commands

```bash
dotfiles-ref   # interactive cheatsheet for this dotfiles setup
tmux-popup     # floating tmux popup terminal
tmux-sessionizer  # fuzzy project/session switcher
```

## Tests

```bash
cd ~/.dotfiles
make test
```

## Structure

```text
~/.dotfiles/
├── runcom/   # .zshrc, .zprofile
├── config/   # zsh/, nvim/, tmux/, ghostty/, git/
├── install/  # Brewfile
├── macos/    # bootstrap-macos.sh
├── bin/      # generic utilities (tmux-popup, tmux-sessionizer)
├── test/
├── docs/
└── Makefile
```

Managed with GNU Stow.

## License

MIT
