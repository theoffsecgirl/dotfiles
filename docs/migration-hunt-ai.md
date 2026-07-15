# Migración a hunt-ai

Se retiran estos comandos:

```text
claude-recon
claude-recon-v2
claude-hypotheses
claude-hypotheses-v2
chatgpt-recon
chatgpt-hypotheses
```

Equivalencias:

```text
claude-recon-v2 <target>       → hunt-ai analyze <target>
claude-hypotheses-v2 <target>  → hunt-ai hypotheses <target>
```

Para generar prompts sin tokens de Claude Code:

```bash
hunt-ai analyze <target> --prompt-only
hunt-ai hypotheses <target> --prompt-only
```

Después de actualizar los dotfiles:

```bash
cd ~/.dotfiles
git pull
./install.sh --dry-run
./install.sh
exec zsh
hunt-doctor
```

Si los binarios retirados siguen apareciendo en `PATH`, revisa enlaces antiguos en `~/.local/bin` y ejecuta de nuevo `stow --restow` mediante `install.sh`.
