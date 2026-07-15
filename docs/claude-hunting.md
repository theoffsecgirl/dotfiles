# Claude Hunting

Esta integración está diseñada para el workflow real del repositorio, no como copia de un framework externo.

## Decisiones

- Un solo ejecutable: `hunt-ai`.
- Los modos se implementan como subcomandos y plantillas.
- Los datos provienen de los outputs existentes del target.
- Caido se consulta mediante MCP y empieza en modo solo lectura.
- Las hipótesis no se presentan como vulnerabilidades.
- El reporte solo se prepara a partir de evidencia validada.
- No se conservan wrappers retirados por compatibilidad indefinida.

## Modos

### `analyze`

Prioriza superficie, hosts y flujos sensibles. No genera tráfico.

### `hypotheses`

Genera un máximo de cinco hipótesis con evidencia, supuesto, prueba mínima y alternativa benigna.

### `caido`

Lee el historial de Caido, agrupa tráfico y compara requests existentes. Prohíbe Replay, Automate, scans, crawlers, workflows, tamper e intercept.

### `report`

Prepara un borrador y marca `NO LISTO` cuando falta reproducción, evidencia o impacto.

### `doctor`

Comprueba Claude Code, `caido-mcp-server` y el registro MCP `caido`.

## Seguridad operacional

Las plantillas aplican estas restricciones:

1. leer scope y out-of-scope antes de analizar;
2. no inventar endpoints, roles, parámetros o impacto;
3. no repetir recon existente;
4. no mostrar secretos o datos personales;
5. no realizar acciones activas desde el modo Caido;
6. mantener separadas hipótesis, validación e impacto.

## Desarrollo futuro

Los siguientes cambios deben demostrar una necesidad real antes de añadirse:

- replay controlado con aprobación explícita;
- perfiles específicos de HackerOne y Bugcrowd;
- actualización estructurada de notas;
- validación de salidas mediante esquemas.

No se añadirán agentes o subcomandos que dupliquen funciones existentes.
