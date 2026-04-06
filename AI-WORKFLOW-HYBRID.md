# Hybrid AI Workflow (Docker + Host)

Separación recomendada:

## Docker (ejecución)
```bash
scope-v2 target.com
webmap-v2 target.com
paramhunt-v2 target.com
```

Outputs en:
```
/work/targets/target.com/
```

## Host (análisis)

### Con Claude (si tienes acceso)
```bash
claude-recon-v2 target.com
claude-hypotheses-v2 target.com
```

### Con ChatGPT (sin CLI)
```bash
chatgpt-recon target.com
chatgpt-hypotheses target.com
```

Abre los ficheros `ai/*.prompt.txt` y pégalos en ChatGPT.

---

## Ventajas
- Docker limpio y reproducible
- Análisis cómodo en host
- No dependes de autenticación Claude
- Compatible con ChatGPT manual

---

## Regla
- datos → Docker
- razonamiento → host
- tooling → dotfiles
