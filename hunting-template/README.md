# Hunting Workspace

Estructura para organizar bug bounty hunting.

## Estructura

```
~/hunting/
├── targets/           # Datos por target
│   └── example.com/
│       ├── recon/
│       ├── vulns/
│       └── notes.md
├── notes/             # Notas generales y metodologías
├── scripts/           # Scripts propios y PoCs
└── templates/         # Templates reutilizables
    └── python-venv/
```

## Setup inicial

```bash
cp -r ~/.dotfiles/hunting-template ~/hunting
cd ~/hunting
```

## Crear venv para proyecto

```bash
cd ~/hunting/scripts
python3 -m venv venv
source venv/bin/activate
pip install requests httpx
```

## Navegación rápida (aliases)

Si aplicas los aliases de `~/.dotfiles/zsh/.config/zsh/aliases.zsh`:

```bash
cdh        # cd ~/hunting
cdt        # cd ~/hunting/targets
cdn        # cd ~/hunting/notes
cds        # cd ~/hunting/scripts
```
