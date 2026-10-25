<!--
GUÍA para el agente, no se copia literal: es el índice de la carpeta `docs/project/decisions/`
(o `agent-context/project/decisions/`). Se genera siempre, también en la etapa `idea/setup`, junto con
`stack.md`. Los demás temas se crean solo cuando hay una decisión que registrar: no se copian vacíos.
El índice lleva una línea por archivo de la carpeta, con el formato exacto de abajo (lo verifica docs-check).
Debe mantenerse corto: se lee cada vez que el agente elige qué tema abrir.
-->

# Decisiones

Decisiones técnicas ya tomadas y cerradas, un archivo por tema, para que un agente no re-litigue un debate resuelto ni revierta algo deliberado. Lee solo el tema que tu tarea toca.

## Índice

<!-- Una línea por tema: `- [tema.md](./tema.md) — cuándo leerlo`. Quitar esta guía al generar. -->

- [stack.md](./stack.md) — antes de agregar, cambiar o quitar una librería, framework o herramienta

## Qué va aquí y qué no

- **Va:** decisiones firmes (qué se eligió, por qué, qué se descartó), un tema por archivo.
- **No va:** lo que aún se evalúa (`handoff.md`, «Decisiones a medio camino»), los servicios externos (`docs/external/`), los bugs y zonas frágiles (`known-issues.md`) ni la estructura del código (`architecture.md`).

## Crear un tema nuevo

Léelo solo si vas a registrar una decisión que no encaja en ningún tema del índice.

1. Si cabe en un tema existente, agrégala ahí; crea un archivo nuevo solo si ninguno encaja.
2. Nombre en minúsculas y con guiones, por tema y no por fecha ni por tarea (`auth.md`, `base-de-datos.md`).
3. Cada entrada, con la más reciente arriba:

   ```
   ## [Fecha] — [Título de la decisión]

   - **Contexto:** qué problema motivó la decisión
   - **Decisión:** qué se decidió, en una o dos líneas
   - **Alternativas consideradas:** qué otras opciones se evaluaron y por qué se descartaron
   - **Consecuencias:** qué implica hacia adelante, incluidos los trade-offs aceptados
   ```

4. No se edita una decisión ya tomada para «corregirla»: si cambia, se agrega una entrada nueva que la reemplaza y referencia la anterior.
5. Suma la línea del tema al índice (formato de arriba, con cuándo leerlo).
