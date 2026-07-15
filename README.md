<div align="center">

![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/Shell-zsh-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-red?style=flat-square)

**Dotfiles for bug bounty and pentesting**  
*by [TheOffSecGirl](https://github.com/theoffsecgirl)*

> 🇪🇸 [Versión en español](README.es.md)

</div>

## What this is

A macOS-first, terminal-centric bug bounty environment built around a reproducible workflow. The repository manages shell configuration, hunting wrappers, tooling installation, target structure and an indexed Claude Code workflow.

## Install

```bash
git clone git@github.com:theoffsecgirl/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

Preview Stow changes without applying them:

```bash
./install.sh --dry-run
```

Machine-specific configuration belongs in `~/.config/zsh/local.zsh`, which is not versioned:

```zsh
export HUNTING_HOME="$HOME/hunting"
```

Validate the environment:

```bash
hunt-doctor
hunt-ai doctor
```

## Bug bounty workflow

### Single-domain target

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

### Multi-domain program

```bash
program-init example
nvim "$HUNTING_HOME/targets/example/in/brief.txt"
program-import-brief example "$HUNTING_HOME/targets/example/in/brief.txt"

nvim "$HUNTING_HOME/targets/example/in/roots.txt"
nvim "$HUNTING_HOME/targets/example/in/scope-web.txt"
nvim "$HUNTING_HOME/targets/example/in/out-of-scope.txt"

scope-program example
webmap example
paramhunt-v2 example
```

Core outputs are kept inside `$HUNTING_HOME/targets/<target>/`:

```text
recon/subdomains.txt
http/live.txt
http/httpx.jsonl
http/urls.txt
http/api_candidates.txt
http/graphql.txt
js/files.txt
fuzz/params.txt
fuzz/sensitive_params.txt
meta/*.json
```

## Indexed AI workflow

`hunt-ai` is the only supported AI entry point. Old `claude-recon`, `claude-hypotheses` and `chatgpt-*` wrappers were removed rather than kept as dead compatibility layers.

```bash
hunt-ai index <target>
hunt-ai analyze <target> --prompt-only
hunt-ai hypotheses <target> --prompt-only
hunt-ai caido <target> --prompt-only
hunt-ai report <target> --prompt-only
```

Remove `--prompt-only` to invoke Claude Code.

The workflow is deliberately staged:

```text
raw recon outputs
    ↓
hunt-ai index
    ↓
ai/context.json
    ↓
analyze → hypotheses → Caido review → report
```

`index` is local and deterministic. It summarizes large files such as `http/httpx.jsonl` into `ai/context.json`, so Claude receives compact structured context instead of raw recon dumps.

Generated artifacts:

```text
ai/context.json
ai/analyze.prompt.md
ai/analyze.md
ai/hypotheses.prompt.md
ai/hypotheses.md
ai/caido.prompt.md
ai/caido.md
ai/report.prompt.md
ai/report.md
```

Rules:

- scope and out-of-scope are read first;
- hypotheses are not treated as confirmed findings;
- `caido` is read-only by default;
- secrets, cookies and authorization headers must not be exposed;
- `report` uses validated evidence, not raw recon;
- missing evidence is stated instead of invented.

See [`docs/ai-workflow.md`](docs/ai-workflow.md) for the full design.

## Caido MCP

The optional Caido MCP integration expects a local MCP server registered as `caido` in Claude Code. `hunt-ai caido` prepares a read-only analysis prompt; it must not replay requests, run Automate, start crawlers or modify traffic.

Check the integration with:

```bash
hunt-ai doctor
claude mcp get caido
```

## Useful commands

```bash
cdh        # $HUNTING_HOME
cdt        # $HUNTING_HOME/targets
bbref      # interactive bug bounty reference
hunt-doctor
hunt-ai doctor
```

Validate command resolution:

```bash
type -a program-init scope-program program-import-brief scope webmap paramhunt-v2 hunt-ai
```

Everything should resolve to `~/.local/bin/*`.

## Tests and audit

```bash
cd ~/.dotfiles
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats
bash audit_dotfiles.sh ~/.dotfiles
```

## Structure

```text
~/.dotfiles/
├── zsh/
├── scripts/
│   └── .local/
│       ├── bin/
│       ├── lib/
│       └── share/hunt-ai/
├── docs/
├── tests/
├── tmux/
├── nvim/
├── ghostty/
├── git/
├── brew/
├── tools/
├── install.sh
└── audit_dotfiles.sh
```

Managed with GNU Stow.

## Ethical use

Only test systems for which you have explicit authorization.

## License

MIT
