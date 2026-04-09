# MANUAL CONTENEDORES

## 1. Para qué sirven

Los contenedores te permiten:
- aislar herramientas
- no ensuciar tu mac
- reproducir entornos
- lanzar tooling pesado sin romper nada

---

## 2. Regla básica

### Host (Mac)
- Burp
- navegador
- tmux
- notas
- scripts ligeros

### Contenedor
- tooling pesado
- escaneos
- entornos raros
- pruebas que rompen cosas

---

## 3. Cuándo usar contenedor

Usa contenedor cuando:
- instalas algo raro
- necesitas dependencias conflictivas
- quieres aislar un entorno
- vas a romper cosas

No uses contenedor para:
- navegar
- Burp
- tareas rápidas

---

## 4. Mentalidad correcta

Contenedor = entorno efímero

- puedes destruirlo
- puedes recrearlo
- no dependes de él

---

## 5. Errores típicos

### Error 1
Meter todo en contenedores.

Resultado: fricción innecesaria.

### Error 2
No montar volúmenes.

Resultado: pierdes datos.

### Error 3
Depender del contenedor como si fuera permanente.

---

## 6. Uso práctico

### Caso 1
Quieres probar tooling nuevo
→ contenedor

### Caso 2
Quieres hacer recon pesada
→ contenedor

### Caso 3
Estás en Burp probando lógica
→ host

---

## 7. Qué te aporta

- limpieza
- seguridad
- reproducibilidad
- separación de contextos

---

## 8. Regla simple

Si dudas:
- rápido → host
- pesado/raro → contenedor
