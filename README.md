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

Preview what stow would link before committing:

```bash
./install.sh --dry-run
```

If something breaks:

```bash
hunt-doctor
```

---

## Bug bounty workflow

### Single-domain target

Use this when one domain maps to one workspace.

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

Official target layout:

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

Use this when one private/public program has several web scopes but you want one workspace.

```bash
program-init example
cd "$HUNTING_HOME/targets/example"
```

Paste/export the brief:

```bash
nvim in/brief.txt
program-import-brief example in/brief.txt
```

Review the extracted scope before recon:

```bash
nvim in/roots.txt
nvim in/scope-web.txt
nvim in/out-of-scope.txt
```

Run the multi-domain flow:

```bash
scope-program example
webmap example
paramhunt-v2 example
```

`scope-program` reads:

```text
in/roots.txt
```

and keeps everything inside:

```text
$HUNTING_HOME/targets/example/
```

It does not create one folder per domain.

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

### Command validation

```bash
type -a program-init scope-program program-import-brief scope webmap mktarget subscan
```

Expected commands should resolve to `~/.local/bin/*`; `tips` is a shell function.

---

## Quick navigation

```bash
cdh        # cd $HUNTING_HOME
cdt        # cd $HUNTING_HOME/targets
cdn        # cd $HUNTING_HOME/notes
cds        # cd $HUNTING_HOME/scripts
```

---

## Interactive cheatsheet

```bash
tips
```

Opens an fzf cheatsheet. Selecting an entry with ENTER copies the command to the clipboard.

---

## General utilities

| Command | Behaviour |
|---|---|
| `grh` | `git reset --hard HEAD` — shows a diff summary and asks for confirmation first |
| `cat` | Automatically uses `bat` if installed (syntax highlighting, no paging) |
| `myip` | Tries three public IP services with a 3s timeout each |
| `localip` | Works on both macOS (`en0`) and Linux (`ip addr`) |
| `git wip` | Stages only tracked files (`add -u`), never untracked secrets |

---

## Tools

Tool installers live in:

```text
tools/install-tools.sh
tools/update-tools.sh
```

Generated binaries and cloned sources are intentionally ignored:

```text
tools/bin/
tools/src/
```

Rebuild local tools with:

```bash
bash ~/.dotfiles/tools/install-tools.sh
```

Update them with:

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

```text
~/.dotfiles/
├── zsh/
├── tmux/
├── nvim/
├── git/
├── ghostty/
├── scripts/
│   └── .local/bin/
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
