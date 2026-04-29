# Hunting Workspace

Estructura para organizar bug bounty hunting.

## Estructura actual

```
~/hunting/
├── targets/
│   └── example.com/
│       ├── recon/
│       ├── http/
│       ├── fuzz/
│       ├── js/
│       ├── in/
│       │   └── resolvers.txt
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

## Flujo recomendado

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
