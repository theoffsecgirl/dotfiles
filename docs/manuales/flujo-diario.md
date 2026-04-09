# MANUAL FLUJO DIARIO

## 1. Objetivo

Trabajar un target sin perder contexto y encontrar bugs de alto impacto.

---

## 2. Flujo correcto

### Crear target
```bash
mktarget example.com
```

### Recon mínima
```bash
scope example.com
webmap example.com
paramhunt example.com
```

---

## 3. Priorizar

Revisar:
- http/live.txt
- http/urls.txt
- js/files.txt
- fuzz/params.txt

Elegir 2-3 superficies interesantes.

---

## 4. Pasar a Burp

Aquí está el dinero.

Probar:
- login
- invites
- orgs/teams
- billing
- exports

---

## 5. Pensamiento ofensivo

Siempre preguntar:
- ¿puedo cambiar el ID?
- ¿puedo repetir la petición?
- ¿puedo cambiar el orden?
- ¿puedo mezclar usuarios?

---

## 6. Uso de helpers

```bash
idor-hints
jwt-decode <token>
race-run request.txt 20
```

---

## 7. Guardar evidencia

Siempre guardar:
- request
- response
- impacto

---

## 8. Qué evitar

- recon infinita
- no usar Burp
- no tomar notas

---

## 9. Regla final

Recon mínima → análisis manual → explotación → evidencia
