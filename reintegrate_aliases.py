#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path.home() / ".dotfiles" / "vendor" / "shell-utils" / "zsh"

FILES = [
    ("aliases-builtin.zsh", "aliases-builtin.zsh.old"),
    ("aliases-bugbounty.zsh", "aliases-bugbounty.zsh.old"),
]

ALIAS_RE = re.compile(r"""^alias\s+([A-Za-z0-9_-]+)=(['"])(.*)\2\s*$""")

def is_complex(cmd: str) -> bool:
    # Cosas que suelen romper o merecen función
    tokens = ["|", "$(", "&&", "||", ";", "`"]
    return any(t in cmd for t in tokens)

def already_defined(text: str, name: str) -> bool:
    # alias name=   o   name() {
    return (
        re.search(rf"^alias\s+{re.escape(name)}=", text, flags=re.M) is not None
        or re.search(rf"^{re.escape(name)}\s*\(\)\s*\{{", text, flags=re.M) is not None
    )

def parse_aliases(old_text: str):
    out = []
    for line in old_text.splitlines():
        line = line.rstrip()
        m = ALIAS_RE.match(line)
        if not m:
            continue
        name, quote, cmd = m.group(1), m.group(2), m.group(3)
        out.append((name, cmd))
    return out

def main():
    for new_name, old_name in FILES:
        new_path = ROOT / new_name
        old_path = ROOT / old_name

        if not new_path.exists():
            raise SystemExit(f"Falta: {new_path}")
        if not old_path.exists():
            print(f"[skip] No existe {old_path}, nada que reintegrar.")
            continue

        new_text = new_path.read_text(encoding="utf-8")
        old_text = old_path.read_text(encoding="utf-8")

        additions = []
        for name, cmd in parse_aliases(old_text):
            if already_defined(new_text, name):
                continue

            if is_complex(cmd):
                additions.append(
                    f"""{name}() {{
  {cmd}
}}"""
                )
            else:
                # Mantener como alias simple (comillas simples para estabilidad)
                safe = cmd.replace("'", r"'\''")
                additions.append(f"alias {name}='{safe}'")

        if not additions:
            print(f"[ok] {new_name}: no hay nada que añadir.")
            continue

        merged = new_text.rstrip() + "\n\n" + "\n".join([
            "# ---------------------------------",
            "# Reintegrado desde legacy (.old)",
            "# ---------------------------------",
            *additions,
            ""
        ])

        new_path.write_text(merged, encoding="utf-8")
        print(f"[done] {new_name}: añadidos {len(additions)} items.")

if __name__ == "__main__":
    main()
