# MANUAL NVIM

## 1. Para qué usar nvim aquí

No es para programar principalmente.

Es para:
- notas
- revisar outputs
- editar requests
- analizar JSON y JS

---

## 2. Uso básico

### Abrir archivo
```bash
nvim archivo.txt
```

### Guardar
```text
:w
```

### Salir
```text
:q
```

---

## 3. Navegación mínima

```text
h j k l   mover
0         inicio línea
$         final línea
gg        inicio archivo
G         final archivo
```

---

## 4. Búsqueda

```text
/palabra
```

n → siguiente

---

## 5. Uso en bug bounty

### Notas
```bash
nvim notes/summary.md
```

### Revisar JSON
```bash
nvim response.json
```

### Revisar endpoints
```bash
nvim http/urls.txt
```

---

## 6. Qué deberías hacer siempre

- tomar notas mientras pruebas
- guardar endpoints interesantes
- documentar hallazgos

---

## 7. Errores típicos

### Error 1
No usarlo → pierdes contexto

### Error 2
No buscar (`/`) → no encuentras nada

### Error 3
No guardar notas → olvidas bugs

---

## 8. Recomendación

No intentes ser experto en vim.

Aprende lo mínimo:
- abrir
- buscar
- editar
- guardar

Eso ya te da ventaja.
