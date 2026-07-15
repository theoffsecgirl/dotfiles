# Hunt AI Workflow

`hunt-ai` unifica el análisis asistido por Claude Code. Sustituye los antiguos scripts `claude-recon*`, `claude-hypotheses*` y `chatgpt-*`.

## Principio

La IA no repite recon ni confirma vulnerabilidades. Trabaja sobre evidencia existente:

```text
scope-program / scope
        ↓
webmap
        ↓
paramhunt-v2
        ↓
hunt-ai analyze
        ↓
hunt-ai hypotheses
        ↓
validación manual o replay controlado
        ↓
hunt-ai report
```

## Comandos

```bash
hunt-ai analyze <target>
hunt-ai hypotheses <target>
hunt-ai caido <target>
hunt-ai report <target>
hunt-ai doctor
```

Cuando Claude Code no tenga acceso, genera el prompt sin ejecutar el modelo:

```bash
hunt-ai analyze <target> --prompt-only
hunt-ai hypotheses <target> --prompt-only
```

Los prompts y resultados se guardan en:

```text
$HUNTING_HOME/targets/<target>/ai/
```

## Qué lee

`hunt-ai` reutiliza, cuando existen:

```text
in/program.md
in/brief.txt
in/roots.txt
in/scope-web.txt
in/out-of-scope.txt
notes/summary.md
notes/overview.md
notes/findings.md
http/live.txt
http/httpx.jsonl
http/api_candidates.txt
http/graphql.txt
js/files.txt
fuzz/params.txt
fuzz/sensitive_params.txt
fuzz/params_by_host.jsonl
```

No ejecuta `scope`, `webmap` ni `paramhunt-v2` automáticamente.

## Caido

`hunt-ai caido` indica a Claude que use el MCP `caido` en modo solo lectura:

- listar y filtrar tráfico existente;
- leer requests y responses capturadas;
- comparar variantes existentes;
- detectar IDs, ownership, roles y cambios de estado.

No debe ejecutar Replay, Automate, scans, crawlers, workflows, tamper ni intercept. Tampoco debe mostrar cookies, cabeceras Authorization, tokens o secretos.

Comprueba la integración con:

```bash
hunt-ai doctor
claude mcp get caido
```

## Separación entre hipótesis y validación

Una hipótesis contiene evidencia, un supuesto y una prueba propuesta. No es un hallazgo.

La validación debe:

1. estar dentro de scope;
2. ser mínima y reversible;
3. usar cuentas o datos de prueba autorizados;
4. registrar resultado esperado y observado;
5. demostrar impacto antes de preparar el reporte.

`hunt-ai report` marca el borrador como `NO LISTO` si falta reproducción, evidencia o impacto demostrado.

## Mantenimiento

Los prompts viven en:

```text
scripts/.local/share/hunt-ai/
```

El ejecutable vive en:

```text
scripts/.local/bin/hunt-ai
```

No vuelvas a añadir wrappers separados por proveedor o por fase. Los nuevos modos deben implementarse como subcomandos y plantillas dentro de `hunt-ai`.
