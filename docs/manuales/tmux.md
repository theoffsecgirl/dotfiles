# MANUAL TMUX

## 1. Qué es tmux

`tmux` es un multiplexor de terminal. Te permite tener varias sesiones, ventanas y paneles dentro de una sola terminal.

En bug bounty sirve para no perder contexto:
- una sesión por target
- una ventana para recon
- una para notas
- una para fuzzing
- una para Burp o logs auxiliares

---

## 2. Por qué te interesa

Sin tmux, acabas con muchas pestañas sueltas y pierdes estado.

Con tmux:
- puedes reconectar una sesión
- no pierdes comandos en ejecución
- mantienes estructura mental fija
- puedes trabajar por target sin mezclar cosas

---

## 3. Conceptos básicos

### Sesión
Un entorno completo de trabajo.

Ejemplo:
```bash
 tmux new -s example
```

### Ventana
Como una pestaña dentro de tmux.

### Panel
División dentro de una ventana.

---

## 4. Tu prefijo

En tu config el prefijo es:
```text
Ctrl+a
```

Cada vez que veas un atajo tipo `prefijo + c`, significa:
1. pulsar `Ctrl+a`
2. soltar
3. pulsar la otra tecla

---

## 5. Atajos esenciales

### Crear sesión
```bash
 tmux new -s target
```

### Ver sesiones
```bash
 tmux ls
```

### Entrar a una sesión existente
```bash
 tmux attach -t target
```

### Salir sin matar la sesión
```text
 prefijo + d
```

Esto es clave: te desconectas, pero todo sigue vivo.

---

## 6. Ventanas

### Nueva ventana
```text
 prefijo + c
```

### Cambiar entre ventanas
```text
 prefijo + n   siguiente
 prefijo + p   anterior
```

### Renombrar ventana
```text
 prefijo + ,
```

---

## 7. Paneles

### Dividir horizontal
```text
 prefijo + |
```

### Dividir vertical
```text
 prefijo + -
```

### Moverte entre paneles
```text
 prefijo + h
 prefijo + j
 prefijo + k
 prefijo + l
```

---

## 8. Flujo recomendado para bug bounty

## Una sesión por target
Ejemplo:
```bash
 tmux new -s example
```

### Ventana 1: recon
Aquí lanzas:
- `scope`
- `webmap`
- `paramhunt`
- `fuzzdirs`

### Ventana 2: notes
Aquí abres:
```bash
 nvim ~/hunting/targets/example.com/notes/summary.md
```

### Ventana 3: js/http
Aquí revisas:
- `http/live.txt`
- `http/urls.txt`
- `js/files.txt`
- `fuzz/params.txt`

### Ventana 4: explotación
Aquí dejas pruebas manuales, curls, requests guardadas y helpers como:
- `jwt-decode`
- `race-run`
- `idor-hints`

---

## 9. Ejemplo real de uso

```bash
mktarget example.com
cd ~/hunting/targets/example.com
tmux new -s example
```

Dentro de tmux:

### Ventana recon
```bash
scope example.com
webmap example.com
paramhunt example.com
```

### Ventana notes
```bash
nvim notes/summary.md
```

### Ventana revisión
```bash
bat http/live.txt
bat http/urls.txt
bat fuzz/params.txt
```

---

## 10. Qué no hacer

### Error 1
Abrir una sesión tmux para todo mezclado.

Hazlo por target.

### Error 2
Usarlo como si fueran pestañas sin estructura.

Debes fijar siempre la misma lógica:
- recon
- notes
- review
- exploit

### Error 3
Cerrar la terminal pensando que lo pierdes todo.

No. Usa:
```text
prefijo + d
```

Y vuelves con:
```bash
tmux attach -t example
```

---

## 11. Qué ventaja te da de verdad

No te da bugs por sí solo.
Te da algo igual de importante:

**persistencia de contexto**.

Y eso en bug bounty vale mucho porque:
- no repites trabajo
- no olvidas endpoints
- no mezclas outputs
- puedes iterar mejor en hallazgos de lógica

---

## 12. Resumen práctico

### Comandos mínimos
```bash
tmux new -s example
tmux ls
tmux attach -t example
```

### Atajos mínimos
```text
prefijo + c   nueva ventana
prefijo + d   detach
prefijo + |   split horizontal
prefijo + -   split vertical
prefijo + h/j/k/l   mover entre paneles
```

### Regla correcta
Un target = una sesión tmux.
