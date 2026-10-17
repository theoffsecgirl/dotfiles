#!/usr/bin/env python3
"""Genera una imagen de vista previa por cada tema (docs/themes/<tema>.png).

Uso (desde la raíz del repo):
    pip install cairosvg            # una vez
    python3 docs/themes/gen-previews.py
Necesita la fuente JetBrains Mono instalada. Vuelve a ejecutarlo cuando añadas
o cambies un tema en config/.config/themes/. Sin cairosvg deja los .svg.
"""
import html
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
THEMES = ROOT / "config/.config/themes"
OUT = ROOT / "docs/themes"

W, H = 560, 215
FONT = "'JetBrains Mono','JetBrainsMono Nerd Font','SF Mono',Menlo,Consolas,monospace"


def load(path):
    txt = path.read_text(encoding="utf-8")
    v = dict(re.findall(r'(\w+)="([^"]*)"', txt))
    return v


def line(y, parts, size=13):
    """parts = [(texto, color, bold?)]"""
    bold = ' font-weight="700"'
    spans = "".join(
        f'<tspan fill="{c}"{bold if b else ""}>{html.escape(t)}</tspan>'
        for t, c, b in parts
    )
    return f'<text x="22" y="{y}" font-size="{size}" xml:space="preserve">{spans}</text>'


def svg(name, v):
    p, s, a, e = v["primary"], v["secondary"], v["accent"], v["extra"]
    t, m, dim = v["text"], v["overlay2"], v["overlay1"]
    out = []
    out.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="{FONT}">')
    out.append(f'<title>Tema {name}</title>')
    out.append(f'<rect width="{W}" height="{H}" rx="12" fill="{v["base"]}"/>')
    # barra de título
    out.append(f'<path d="M12 0h{W-24}a12 12 0 0 1 12 12v18H0V12A12 12 0 0 1 12 0z" fill="{v["mantle"]}"/>')
    for i, c in enumerate((v["c1"], v["c3"], v["c2"])):
        out.append(f'<circle cx="{22 + i * 18}" cy="15" r="5.5" fill="{c}"/>')
    out.append(f'<text x="{W/2}" y="19.5" font-size="12" text-anchor="middle" fill="{m}">{html.escape(name)}</text>')

    hdr = v.get("THEME_FF_HEADER", "SYSTEM ONLINE")
    sub = v.get("THEME_FF_SUB", "// access granted")
    y = 56
    out.append(line(y, [("▓▒░ ", a, False), (hdr, s, True), (" ░▒▓  ", a, False), (sub, p, False)]))
    y += 30
    out.append(line(y, [("╭─ ", p, True), ("theoffsecgirl", s, True), ("@", a, False), ("macbook ", a, True),
                        ("~/hunting ", p, True), ("on ", m, False), (" main ", e, True), ("[!]", v["yellow"], True)]))
    y += 21
    out.append(line(y, [("╰─", p, True), ("❯", p, True), ("❯", s, True), ("❯ ", a, True), ("nmap -sV target.local", t, False)]))
    y += 24
    out.append(line(y, [("22/tcp  ", t, False), ("open     ", v["green"], True), ("ssh      OpenSSH 9.6", t, False)]))
    y += 19
    out.append(line(y, [("443/tcp ", t, False), ("open     ", v["green"], True), ("https    nginx 1.27", t, False)]))
    y += 19
    out.append(line(y, [("445/tcp ", t, False), ("filtered ", v["red"], True), ("microsoft-ds", dim, False), ("   # revisar luego", dim, False)]))

    # paleta ANSI
    gap, x0, yb = 4, 22, H - 34
    sw = (W - 2 * x0 - 15 * gap) / 16
    for i in range(16):
        out.append(f'<rect x="{x0 + i * (sw + gap)}" y="{yb}" width="{sw}" height="14" rx="3" fill="{v["c" + str(i)]}"/>')
    out.append("</svg>")
    return "\n".join(out) + "\n"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    names = sorted(f.stem for f in THEMES.glob("*.theme"))
    try:
        import cairosvg
    except ImportError:
        cairosvg = None
        print("aviso: sin cairosvg; genero .svg en vez de .png (pip install cairosvg)")
    for n in names:
        code = svg(n, load(THEMES / f"{n}.theme"))
        if cairosvg:
            cairosvg.svg2png(bytestring=code.encode(), write_to=str(OUT / f"{n}.png"), output_width=W * 2)
        else:
            (OUT / f"{n}.svg").write_text(code, encoding="utf-8")
    print(f"{len(names)} previews en {OUT.relative_to(ROOT)}/")


if __name__ == "__main__":
    main()
