# Hunting Workspace

Estructura para organizar bug bounty hunting.

## Estructura actual

```
~/hunting/
├── targets/
│   └── example/
│       ├── recon/
│       ├── http/
│       ├── fuzz/
│       ├── js/
│       ├── in/
│       │   ├── brief.txt
│       │   ├── roots.txt
│       │   ├── scope-web.txt
│       │   └── out-of-scope.txt
│       ├── out/
│       ├── tmp/
│       ├── burp/
│       ├── notes/
│       │   └── summary.md
│       ├── reports/
│       ├── loot/
│       └── meta/
├── notes/
├── scripts/
└── templates/
```

## Setup inicial

```bash
cp -r ~/.dotfiles/hunting-template ~/hunting
cd ~/hunting
```

## Flujo multi-dominio (recomendado para privados)

```bash
program-init example
cd "$HUNTING_HOME/targets/example"

nvim in/brief.txt
program-import-brief example in/brief.txt

scope-program example
webmap example
paramhunt-v2 example
```

## Flujo single-domain

```bash
mktarget example.com
scope example.com
webmap example.com
paramhunt-v2 example.com
```

## Navegación rápida

```bash
cdh        # cd ~/hunting
cdt        # cd ~/hunting/targets
cdn        # cd ~/hunting/notes
cds        # cd ~/hunting/scripts
```
