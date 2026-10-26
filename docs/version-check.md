# Chequeo de versión de la skill

Detecta si un proyecto con documentación ya generada se creó con una versión de la skill distinta de la instalada, avisa y ofrece una revisión; también ofrece renombrar los marcadores de máquina con prefijo heredado (ver «Marcadores heredados»). **No edita nada sin confirmación del operador.**

## Cuándo se corre

Al aplicar la skill sobre un repo con documentación (Paso 1 de [`../SKILL.md`](../SKILL.md)), antes de la tarea pedida.

## Cómo se lee

1. `head -n 3` de `docs/agents/rules.md` (o `agent-context/agents/rules.md`). No se abre el archivo entero. Si no está donde se espera, usar la carpeta del `handoff.md` firmado (ver «Prioridad» en [`migration-flow.md`](./migration-flow.md)).
2. Buscar el marcador con la regex `<!-- agent-context-(?:skill|kit):version (\d+\.\d+\.\d+)[^>]*-->` (acepta el prefijo anterior `agent-context-kit:`; formato y dónde va: «Marcador de versión» en [`template-architecture.md`](./template-architecture.md)).
3. Comparar ese valor con la «Versión de esta skill» de `SKILL.md`, por componentes numéricos (major, minor, patch), no como texto.

## Casos

- **Igual** → no decir nada de la versión; seguir con «Marcadores heredados» y luego con la tarea.
- **Marcador ausente** → versión desconocida (los proyectos generados antes de la 1.9.0 no lo tienen). Se trata como «más vieja».
- **Proyecto más nuevo que la skill** → avisar que la skill instalada es anterior a la que generó el proyecto, no tocar nada y sugerir actualizar la skill.
- **Proyecto más viejo o desconocida** → preguntar en texto, como mensaje final del turno: la diferencia (ej. «el proyecto se generó con 1.8.0; la skill es 1.9.0») y los títulos de los cambios del changelog que se aplicarían como contexto y, debajo, «Actualizar» / «Solo revisar» / «Ahora no»; se espera la respuesta en el chat.
  - «Actualizar» → seguir [`update-flow.md`](./update-flow.md).
  - «Solo revisar» → la revisión por diff de abajo; es también el respaldo cuando el changelog no cubre el salto.
  - «Ahora no» → seguir con la tarea y no volver a preguntar en esa sesión.

## Marcadores heredados

Los proyectos anteriores a la 2.0.0 llevan en sus archivos de máquina los prefijos heredados: `agent-context-kit:` en anclas (`section=`), marcador de versión y firma (`signature`), y `agent-docs-skill:` en los bloques `start`/`end` de `AGENTS.md` y `CLAUDE.md`. Los scripts y la skill los siguen leyendo, pero la skill nunca los escribe.

- **Cuándo:** en todo caso de «Casos» salvo «Proyecto más nuevo que la skill», también si la versión es «Igual», una vez resuelto el caso (son turnos separados: primero la pregunta del caso, después esta). Si el operador eligió «Actualizar», el renombrado del cambio «Un solo prefijo» lo hace [`update-flow.md`](./update-flow.md) con este mismo procedimiento; al terminar la actualización se repite la detección y, si aún queda algún prefijo heredado (cambio omitido, hecho a medias o escrito a mano), se pregunta como aquí.
- **Detectar:** `grep -rnE` (o la herramienta de búsqueda) con el patrón `<!--s*(agent-context-kit:(section|version|signature)|agent-docs-skill:(start|end))` en `docs/agents/` (o `agent-context/agents/`, o la carpeta del `handoff.md` firmado si el proyecto movió carpetas; en multi incluye las carpetas de operador, `operators.md` y `team-backlog.md`) y en el `AGENTS.md` y `CLAUDE.md` de la raíz, **sin `history.md`** (es registro histórico del proyecto, no se reescribe). Anclar el patrón a `<!--` evita falsos positivos de prosa; también coincide la guía de anclas de `handoff.md` y `backlog.md`, que cita `<!-- agent-context-kit:section=... -->` entre acentos graves: esa cita se renombra igual. Sin resultados: no decir nada.
- **Con resultados:** preguntar en texto, como mensaje final del turno (regla 5 de [`asking-questions.md`](./asking-questions.md)): la lista de archivos y números de línea afectados como contexto y, debajo, «Renombrar» / «Ahora no»; se espera la respuesta en el chat. «Ahora no» → seguir con la tarea y no volver a preguntar en esa sesión.
- **Renombrar:** solo con «Renombrar». En cada coincidencia, reemplazar el prefijo por `agent-context-skill:` sin tocar nada más del archivo (ni el resto del comentario). Con la herramienta de edición, línea por línea (no `sed -i`: cambia entre sistemas operativos). Al terminar, repetir el `grep` y comprobar que no queda ninguno. Los cambios quedan sin commitear en el árbol de trabajo, para que el operador los revise con `git diff`.

## Revisión (solo si el operador elige «Solo revisar»)

Comparar **solo** las partes que la plantilla controla, por rangos, sin leer todo:

- `rules.md`: las secciones «Reglas por defecto (fijas…)» y «Al cerrar una tarea (fijas…)» contra `template/agents/rules.md`. Se excluye la regla «Idioma de la documentación» (valor propio del proyecto).
- Multi-operador: además el bloque «Trabajo en paralelo» contra `template/multi/rules.md`.
- `AGENTS.md` y `CLAUDE.md` de la raíz: los bloques delimitados por `agent-context-skill:start/end` (o el prefijo anterior `agent-docs-skill:start/end`) contra `template/AGENTS.md` (o `template/multi/AGENTS.md`) y `template/CLAUDE.md`.

Mostrar cada diferencia al operador sin decidir cuál es «la correcta»: puede ser una edición intencional del proyecto.

## Qué se edita y qué no

Nada, salvo el renombrado confirmado de «Marcadores heredados» y lo que el operador pida diferencia por diferencia; al terminar la revisión se pregunta en texto, como mensaje final del turno, con las diferencias encontradas como contexto, si actualizar el marcador, y solo con sí se reescribe la línea 1 de `rules.md`.

## Alcance

- Actualizar entre versiones es [`update-flow.md`](./update-flow.md); migrar documentación de otros sistemas es [`migration-flow.md`](./migration-flow.md).
- No compara `handoff.md`, `backlog.md` ni `history.md`: son contenido del proyecto (solo se renombra el prefijo de máquina de los dos primeros, nunca el de `history.md`).
