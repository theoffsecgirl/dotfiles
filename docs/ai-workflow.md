# Hunt AI — workflow indexado para bug bounty

`hunt-ai` convierte outputs locales de recon en contexto estructurado para Claude Code y Caido MCP. Sustituye los antiguos wrappers `claude-recon`, `claude-hypotheses` y `chatgpt-*`.

## Principio

Claude no debe recibir volcados brutos de recon.

```text
scope / webmap / paramhunt
          ↓
    outputs locales
          ↓
    hunt-ai index
          ↓
     ai/context.json
          ↓
 analyze → hypotheses → caido → report
```

`index` es local, determinista y no usa IA.

## Comandos

```bash
hunt-ai index <target>
hunt-ai analyze <target> [--prompt-only]
hunt-ai hypotheses <target> [--prompt-only]
hunt-ai caido <target> [--prompt-only]
hunt-ai report <target> [--prompt-only]
hunt-ai doctor
```

`--prompt-only` genera el prompt pero no invoca Claude Code.

## Indexación

`hunt-ai index` lee:

- `in/roots.txt`;
- `in/scope-web.txt`;
- `in/out-of-scope.txt`;
- `in/program.md`;
- `notes/summary.md`;
- `http/httpx.jsonl`;
- `http/api_candidates.txt`;
- `http/graphql.txt`;
- `http/urls.txt`;
- `fuzz/sensitive_params.txt`.

Y genera:

```text
ai/context.json
```

El contexto incluye:

- scope y exclusiones;
- resumen del programa;
- inventario de hosts;
- estados HTTP;
- tecnologías;
- endpoints y URLs candidatas;
- GraphQL;
- parámetros sensibles;
- evidencia disponible.

Los ficheros grandes se procesan línea a línea y no se copian completos al prompt.

## Fases

### Analyze

Entrada principal: `ai/context.json`.

Objetivo: resumir superficie, priorizar activos y señalar información que falta. No declara vulnerabilidades.

```bash
hunt-ai analyze doximity --prompt-only
```

### Hypotheses

Entradas: contexto + `ai/analyze.md` cuando existe.

Objetivo: devolver un máximo de cinco hipótesis justificadas, con evidencia, precondiciones, prueba mínima y alternativa benigna.

```bash
hunt-ai hypotheses doximity --prompt-only
```

### Caido

Entradas: contexto + resumen del target. Usa el MCP `caido`.

Modo por defecto:

- listar, buscar, leer y comparar tráfico existente;
- no Replay;
- no Automate;
- no scans ni crawlers;
- no exposición de secretos;
- no peticiones nuevas.

```bash
hunt-ai caido doximity --prompt-only
```

### Report

Entradas: `notes/findings.md`, `ai/caido.md` y `ai/hypotheses.md` cuando existen.

Solo debe producir un reporte listo cuando la reproducción, el resultado observado y el impacto estén demostrados. En caso contrario marca `NO LISTO`.

```bash
hunt-ai report doximity --prompt-only
```

## Artefactos

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

## Validación real

Prueba realizada con el target local `doximity`:

```text
http/httpx.jsonl   169242 bytes
ai/context.json     40184 bytes

analyze.prompt.md    41598 bytes
hypotheses.prompt.md 41803 bytes
caido.prompt.md      43165 bytes
report.prompt.md     41790 bytes
```

La versión anterior generaba prompts de aproximadamente 181 KB porque copiaba `httpx.jsonl`. El flujo indexado los reduce a unas decenas de KB y evita incluir el JSONL bruto.

El indexador detectó en esa prueba:

```text
92 hosts
40 URLs candidatas
estados HTTP agregados
tecnologías agregadas
```

Que `interesting_endpoints` sea cero puede ser válido cuando `httpx.jsonl` contiene principalmente URLs raíz; los paths se recuperan también desde `http/urls.txt` y aparecen en `candidate_urls`.

## Tests

```bash
cd ~/.dotfiles
bash -n scripts/.local/bin/hunt-ai
bash -n scripts/.local/bin/hunt-doctor
bats tests/test_hunt_ai.bats
```

Cobertura actual:

- ayuda sin argumentos;
- generación de contexto JSON;
- prompt compacto sin JSONL bruto;
- reutilización de análisis para hipótesis;
- rechazo de subcomandos desconocidos.

## Seguridad

- trabajar solo dentro de scope;
- leer out-of-scope antes de analizar;
- no inventar endpoints, roles, respuestas o impacto;
- no convertir hipótesis en findings;
- no mostrar tokens, cookies, `Authorization` o datos personales;
- usar pruebas mínimas, reversibles y de bajo volumen;
- mantener Caido en solo lectura salvo autorización explícita posterior.
