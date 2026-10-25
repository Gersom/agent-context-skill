# Changelog de la skill

Qué cambió de cada versión **en lo que ya está generado en los proyectos**. Lo lee el agente al actualizar un proyecto ([`../version-check.md`](../version-check.md), [`../update-flow.md`](../update-flow.md)) y lo escribe quien publica una versión. No es un historial de commits: solo entran los cambios que un proyecto ya generado tendría que aplicar.

## Archivos

- Un archivo por cada versión **minor o major**: `X.Y.md` (`1.9.md`, `1.10.md`, `2.0.md`).
- Las versiones **patch** van como secciones dentro del archivo de su minor (`## 1.9.2`). Un patch también puede cambiar texto fijo.
- Cada minor o major lleva su archivo aunque no cambie nada que aplicar (entonces dice «Sin cambios que aplicar»).

## Estructura de un archivo

```
# X.Y
Una o dos líneas: qué trae esta serie.

## X.Y.0
### Cambio 1 — título corto
- **Tipo:** insertar | reemplazar | eliminar | manual
- **Archivo:** rules.md | AGENTS.md | CLAUDE.md | cualquiera (solo manual)
- **Plantilla:** ruta en template/ de la que sale el texto (opcional en «manual»)
- **Ubicación:** dónde está en el archivo del proyecto (línea 1, o el título de la sección)
- **Modo:** todos | multi (opcional; por defecto todos)
- **Texto anterior:** bloque de código con el texto exacto (solo reemplazar y eliminar)
- **Texto nuevo:** bloque de código con el texto exacto (solo insertar y reemplazar)
- **Instrucción:** qué hacer (solo manual)
```

## Reglas

- Solo partes que la plantilla controla: las reglas fijas de `rules.md` y los bloques `agent-context-skill:start/end` de `AGENTS.md` y `CLAUDE.md`. El resto es contenido del proyecto. Excepción: el tipo `manual` puede referirse a cualquier archivo generado (p. ej. `handoff.md`).
- **Tipos:** `insertar` (texto que no existía), `reemplazar` (el texto anterior pasa a ser el nuevo), `eliminar` (el texto anterior desaparece), `manual` (cambios de estructura, como un campo nuevo en `handoff.md`: se describen y el agente ayuda a aplicarlos, no se automatizan).
- Los textos van **exactos**, en bloques de código, para poder compararlos con lo que tiene el proyecto.
- `{{versión}}` en un texto es la versión de la skill a la que se actualiza (lo usa el marcador de versión).
- Los textos del changelog están en el idioma de la plantilla (español); el agente los adapta al `IDIOMA` del proyecto (ver [`../update-flow.md`](../update-flow.md)).
- Dentro de una serie, las secciones van de la más vieja a la más nueva.

## Aplicar a mano, sin la skill

Un proyecto que ya no usa la skill conserva el texto con el que se generó. Para ponerlo al día sin correrla: leer las secciones `## X.Y.Z` posteriores a la versión de su `rules.md` (línea 1) y, en cada cambio, buscar el «Texto anterior» en el archivo indicado y reemplazarlo por el «Texto nuevo»; si no coincide, es una edición propia del proyecto y se decide a mano. Al terminar, subir la versión de la línea 1. Los cambios de tipo `manual` traen su instrucción.
