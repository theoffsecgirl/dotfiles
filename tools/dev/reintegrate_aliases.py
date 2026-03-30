#!/usr/bin/env python3
"""
Herramienta de migración — movida a tools/dev/ (no es de uso final).
Script original usado para reintegrar aliases durante la reestructuración del repo.
"""

import re
import sys
from pathlib import Path


def parse_aliases(filepath: str) -> dict:
    """Extrae aliases de un fichero zsh."""
    aliases = {}
    path = Path(filepath)
    if not path.exists():
        print(f"Error: {filepath} no existe", file=sys.stderr)
        return aliases

    content = path.read_text(encoding="utf-8")
    pattern = re.compile(r"^alias\s+(\w+)=['\"](.+?)['\"]\s*$", re.MULTILINE)
    for match in pattern.finditer(content):
        name, value = match.group(1), match.group(2)
        aliases[name] = value
    return aliases


def merge_aliases(source: str, target: str, dry_run: bool = True):
    """Fusiona aliases de source en target, evitando duplicados."""
    source_aliases = parse_aliases(source)
    target_aliases = parse_aliases(target)

    new_aliases = {
        k: v for k, v in source_aliases.items()
        if k not in target_aliases
    }

    if not new_aliases:
        print("No hay aliases nuevos que añadir.")
        return

    print(f"Aliases nuevos encontrados ({len(new_aliases)}):")
    for name, value in new_aliases.items():
        print(f"  alias {name}='{value}'")

    if dry_run:
        print("\n[dry-run] No se ha modificado ningún fichero.")
        return

    with open(target, "a", encoding="utf-8") as f:
        f.write("\n# Aliases reintegrados\n")
        for name, value in new_aliases.items():
            f.write(f"alias {name}='{value}'\n")

    print(f"\nAliases añadidos a {target}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: reintegrate_aliases.py <source.zsh> <target.zsh> [--apply]")
        sys.exit(1)

    source_file = sys.argv[1]
    target_file = sys.argv[2]
    apply = "--apply" in sys.argv

    merge_aliases(source_file, target_file, dry_run=not apply)
