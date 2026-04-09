# AI Workflow for Bug Bounty Recon

Pipeline orientado a reducir ruido y convertir outputs de recon en hipótesis accionables.

---

## Flujo recomendado

```bash
scope-v2 target.com
webmap-v2 target.com
paramhunt-v2 target.com
claude-recon target.com
claude-hypotheses target.com
```

---

## Objetivo

Pasar de:

```text
recon -> listas planas
```

A:

```text
recon -> dataset estructurado -> priorización -> hipótesis -> validación manual
```

---

## Artefactos generados

### scope-v2
- `recon/subdomains.txt`
- `http/live.txt`
- `http/httpx.jsonl`
- `http/httpx_table.tsv`
- `meta/scope.json`

### webmap-v2
- `http/katana.jsonl`
- `http/urls.txt`
- `http/urls_clean.txt`
- `http/api_candidates.txt`
- `http/graphql.txt`
- `js/files.txt`
- `meta/webmap.json`

### paramhunt-v2
- `fuzz/params.txt`
- `fuzz/params_by_url.tsv`
- `fuzz/sensitive_params.txt`
- `fuzz/params_by_host.jsonl`
- `meta/paramhunt.json`

### claude-recon
- `ai/recon.json`

### claude-hypotheses
- `ai/hypotheses.json`

---

## Priorización práctica

Prioriza:
- endpoints `/api/`, `/graphql`, `/v1/`, `/v2/`
- parámetros `id`, `user_id`, `account_id`, `redirect`, `token`, `file`
- paneles internos, seller, billing, admin, support
- bundles JS con lógica de roles o feature flags

Evita perder tiempo en:
- estáticos
- assets de marketing
- endpoints sin estado ni contexto de negocio

---

## Validación

Claude propone hipótesis. La validación sigue siendo manual.

Checklist:
1. reproducir request en Burp
2. modificar identificadores
3. observar diferencias de autorización
4. probar desincronización de estados si aplica
5. documentar señal esperada vs observada

---

## Seguridad

La carpeta `.claude/settings.json` limita lectura/escritura sobre secretos, loot y `.env`.

No uses Claude como confirmador de bugs. Úsalo como:
- clasificador
- resumidor
- generador de hipótesis
- asistente de reporting
