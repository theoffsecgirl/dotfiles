# Claude Code + Caido MCP

Prerequisitos:

```bash
caido-cli --version
caido-mcp-server --version
claude --version
```

Registro recomendado:

```bash
claude mcp add \
  --transport stdio \
  --scope user \
  caido \
  -- \
  "$HOME/.local/bin/caido-mcp-server" \
  serve \
  -u http://127.0.0.1:8080
```

Comprobación:

```bash
claude mcp get caido
claude mcp list
hunt-ai doctor
```

El MCP debe aparecer conectado y sin variables de entorno pendientes.

`hunt-ai caido <target>` genera una instrucción de análisis en modo solo lectura. Caido debe estar abierto y escuchando en `127.0.0.1:8080` cuando Claude ejecute el prompt.

No guardes PAT, tokens OAuth ni cookies en el repositorio.
