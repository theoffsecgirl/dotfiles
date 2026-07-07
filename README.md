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

This is my real bug bounty working environment — macOS-first, terminal-centric, built around a reproducible workflow.

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
```

After install, set your real workspace path (see [Configuration](#configuration)), then:

```bash
exec zsh
```

Preview what stow would link without applying:

```bash
./install.sh --dry-run
```

If something breaks:

```bash
hunt-doctor
```

`hunt-doctor` validates the full environment: required tools (subfinder, httpx, katana, dnsx, nuclei, jq, unfurl, anew), all pipeline scripts, stable wrappers, and optional tools referenced in `bbref` (uro, dalfox, gau, waybackurls, gowitness, trufflehog, subjs, ffuf, feroxbuster, amass, assetfinder, subjack).

---

## Configuration

All real configuration lives in `~/.config/zsh/load.zsh` (not `.zshrc`, which is intentionally minimal).

Machine-specific overrides go in `~/.config/zsh/local.zsh` — this file is **not versioned**. The installer creates a template automatically.

The most important override is `HUNTING_HOME`:

```zsh
# ~/.config/zsh/local.zsh
export HUNTING_HOME="$HOME/Library/Mobile Documents/com~apple~CloudDocs/02_PROFESIONAL/bugbounty"
```

If `HUNTING_HOME` is not set here, it falls back to `~/targets` — which works but won't point to iCloud.

---

## Bug bounty workflow

### Single-domain target

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

Target layout:

```text
$HUNTING_HOME/targets/example.com/
├── recon/
├── http/
├── fuzz/
├── js/
├── in/
│   └── resolvers.txt
├── out/
├── tmp/
├── burp/
├── notes/
│   └── summary.md
├── reports/
├── loot/
└── meta/
```

Main outputs:

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
http/urls.txt
http/urls_clean.txt
http/api_candidates.txt
js/files.txt
fuzz/urls_with_params.txt
fuzz/params.txt
meta/*.json
```

### Multi-domain program

Use when a private/public program has multiple web scopes but you want one workspace.

```bash
program-init example
cd "$HUNTING_HOME/targets/example"
```

Import the brief:

```bash
nvim in/brief.txt
program-import-brief example in/brief.txt
```

Review extracted scope before recon:

```bash
nvim in/roots.txt
nvim in/scope-web.txt
nvim in/out-of-scope.txt
```

Run multi-domain flow:

```bash
scope-program example
webmap example
paramhunt-v2 example
```

`scope-program` reads `in/roots.txt` and keeps everything inside `$HUNTING_HOME/targets/example/` — no per-domain subdirectories.

Expected multi-domain outputs:

```text
recon/subdomains.txt
recon/roots/<root>.subdomains.txt
http/live.txt
http/httpx.jsonl
http/httpx_table.tsv
http/roots/<root>.live.txt
meta/scope-program.json
meta/roots/<root>.scope.json
```

### Validate commands

```bash
type -a program-init scope-program program-import-brief scope webmap mktarget subscan
```

Expected: everything resolves to `~/.local/bin/*`. `tips` is a shell function.

---

## Quick navigation

```bash
cdh        # cd $HUNTING_HOME
cdt        # cd $HUNTING_HOME/targets
cdn        # cd $HUNTING_HOME/notes
cds        # cd $HUNTING_HOME/scripts
```

---

## Proxy (Burp Suite)

```bash
setproxy      # activates http_proxy + https_proxy → 127.0.0.1:8080
              # also sets no_proxy=localhost,127.0.0.1 so CLI tools
              # don't route local traffic through Burp
unsetproxy    # clears all three variables
```

---

## Interactive cheatsheet

```bash
bbref
```

Opens an fzf cheatsheet of bug bounty commands organised by category (setup, recon, http, fuzz, params, JS, secrets, wordlists, tmux, findings). Press ENTER to copy the selected snippet to the clipboard.

```bash
tips
```

General shell tips cheatsheet (git, proxy, navigation). Also opens with fzf + copy.

---

## General utilities

| Command | Behaviour |
|---|---|
| `grh` | `git reset --hard HEAD` — shows a diff summary and asks for confirmation |
| `rmrf` | `rm -rf` with a preview of what will be deleted and a confirmation prompt — same pattern as `grh` |
| `ll` / `la` | Uses `eza` or `lsd` if installed, falls back to `ls -lAh` / `ls -A` |
| `cat` | Automatically uses `bat --style=plain` if installed (syntax highlighting, no paging, no decorations) |
| `myip` | Tries three public IP services with a 3s timeout each |
| `localip` | Works on both macOS (`en0`) and Linux (`ip addr`) |
| `git wip` | Stages only tracked files (`add -u`), never untracked secrets |
| `setproxy` / `unsetproxy` | Toggle Burp proxy with `no_proxy` for localhost |
| `purge_outputs` | Removes `output/` dirs and `.log` files — asks for confirmation |

---

## Tools

```bash
bash ~/.dotfiles/tools/install-tools.sh   # install Go tools (ProjectDiscovery, tomnomnom)
bash ~/.dotfiles/tools/update-tools.sh    # update them
```

Brew dependencies are managed via `brew/Brewfile` — the single source of truth for macOS packages:

```bash
brew bundle --file=~/.dotfiles/brew/Brewfile
```

---

## Offsec container (optional)

```bash
offsec-up       # start container (alias: offsec-start)
offsec-shell    # exec into zsh in the container
```

The container mounts `$HUNTING_HOME` at `/work`.

---

## Dotfiles audit

```bash
bash ~/.dotfiles/audit_dotfiles.sh ~/.dotfiles
```

Checks: merge conflicts, CRLF, `sh` bashisms, bash/zsh syntax errors, shellcheck (requires `shellcheck` — included in the Brewfile), and duplicate zsh functions across all files loaded from `load.zsh`.

---

## Structure

```text
~/.dotfiles/
├── zsh/
│   ├── .zshrc                    # minimal — loads load.zsh
│   └── .config/zsh/
│       ├── load.zsh              # modular entry point
│       ├── aliases-general.zsh   # git, nav, system
│       ├── bug-bounty.zsh        # hunting workspace
│       └── bbref.zsh             # interactive bug bounty cheatsheet
├── tmux/
├── nvim/
├── ghostty/
├── scripts/
│   └── .local/bin/               # all hunting scripts
├── vendor/
│   └── shell-utils/zsh/          # cross-platform helpers
├── brew/
│   └── Brewfile                  # macOS package source of truth
├── tools/
│   ├── install-tools.sh
│   └── update-tools.sh
├── audit_dotfiles.sh
└── install.sh
```

Managed with [GNU Stow](https://www.gnu.org/software/stow/) — clean, reversible symlinks.

---

## Ethical use

Only on systems you have permission to test.

---

## License

MIT
