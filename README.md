<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen?style=flat-square)

---
**Dotfiles for bug bounty and pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇪🇸 [Versión en español](README.es.md)

</div>

---

## What is this

These are not "pretty dotfiles".

This is my real bug bounty working environment.

Designed to:

- stop wasting time on setup
- keep the same workflow everywhere
- automate repetitive tasks
- go straight to finding bugs

---

## Setup

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

If something breaks:

```bash
hunt-doctor
```

---

## How to use it

### 1. Create target

```bash
mktarget example.com
```

Workspace:

```
~/hunting/targets/example.com
```

---

### 2. Recon

```bash
recon example.com
```

Runs subenum → probe → auto note. Subdomains saved to `~/hunting/targets/example.com/subdomains.txt`.

```bash
subenum example.com   # subdomains only
inscope example.com   # filter in-scope (legacy helper)
```

---

### 3. Nuclei

```bash
nuc -l urls.txt       # nuclei -silent
nucl urls.txt         # against CVEs, saves result
```

---

### 4. HTTP

```bash
h      # httpx -silent
hh     # httpx + tech-detect + status-code
hhh    # httpx + tech-detect + title + web-server
f      # ffuf -c -mc all -fc 404
```

---

### 5. Interactive cheatsheet

```bash
tips
```

Opens an fzf browser with all aliases organized by category (git, recon, docker, navigation, utilities). Type to filter, ESC to exit.

---

## Quick navigation

[`zoxide`](https://github.com/ajeetdsouza/zoxide) learns your most used directories:

```bash
z hunting       # jump to ~/hunting
z dotfiles      # jump to ~/.dotfiles
zi              # interactive selector with fzf
dotfiles        # direct alias to ~/.dotfiles
hunting         # direct alias to ~/hunting
```

---

## Advanced history

[`atuin`](https://github.com/atuinsh/atuin) replaces zsh history with semantic search and context (directory, exit code, duration):

```bash
Ctrl+R   # interactive history search
```

---

## Git aliases

| Alias | Command |
|-------|--------|
| `gs` | `git status -sb` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gc 'msg'` | `git commit -m` |
| `gca` | `git commit --amend --no-edit` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gst` / `gstp` | `git stash` / `git stash pop` |
| `glog` | full graph log |

---

## Included tools

Auto-installed in `~/.local/tools/` by `./install.sh`:

| Tool | Usage |
|------|-------|
| `webxray` | Offensive web scanner: XSS, SQLi, headers, WAF bypass |
| `pathraider` | LFI and path traversal with encoding bypass |
| `bbcopilot` | AI bug bounty assistant with local methodology vault |
| `takeovflow` | Subdomain takeover detection |
| `bluedeath` | Offensive shell tool |

Update all tools:

```bash
bash ~/.dotfiles/tools/update-tools.sh
```

---

## Offsec container (optional)

```bash
offsec-up       # start container
offsec-shell    # enter container
offsec          # exec directly into zsh in container
```

---

## Structure

```
~/.dotfiles/
├── zsh/
│   └── .config/zsh/
│       ├── load.zsh           # main loader
│       ├── bug-bounty.zsh     # recon functions and aliases
│       └── aliases-general.zsh # productivity aliases
├── tmux/
├── nvim/
├── git/
├── ghostty/
├── scripts/
├── tools/
│   ├── install-tools.sh
│   └── update-tools.sh
└── install.sh
```

Managed with stow — clean, reversible symlinks.

---

## Ethical use

Only on systems you have permission to test.

---

## License

MIT
