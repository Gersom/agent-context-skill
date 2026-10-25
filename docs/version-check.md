# Chequeo de versión de la skill

Detecta si un proyecto con documentación ya generada se creó con una versión de la skill distinta de la instalada, avisa y ofrece una revisión. **No edita nada por su cuenta.**

## Cuándo se corre

Al aplicar la skill sobre un repo con documentación (Paso 1 de [`../SKILL.md`](../SKILL.md)), antes de la tarea pedida.

## Cómo se lee

1. `head -n 3` de `docs/agents/rules.md` (o `agent-context/agents/rules.md`). No se abre el archivo entero. Si no está donde se espera, usar la carpeta del `handoff.md` firmado (ver «Prioridad» en [`migration-flow.md`](./migration-flow.md)).
2. Buscar el marcador con la regex `<!-- agent-context-(?:skill|kit):version (\d+\.\d+\.\d+)[^>]*-->` (acepta el prefijo anterior `agent-context-kit:`; formato y dónde va: «Marcador de versión» en [`template-architecture.md`](./template-architecture.md)).
3. Comparar ese valor con la «Versión de esta skill» de `SKILL.md`, por componentes numéricos (major, minor, patch), no como texto.

## Casos

- **Igual** → no decir nada y seguir con la tarea.
- **Marcador ausente** → versión desconocida (los proyectos generados antes de la 1.9.0 no lo tienen). Se trata como «más vieja».
- **Proyecto más nuevo que la skill** → avisar que la skill instalada es anterior a la que generó el proyecto, no tocar nada y sugerir actualizar la skill.
- **Proyecto más viejo o desconocida** → preguntar en texto, como mensaje final del turno: la diferencia (ej. «el proyecto se generó con 1.8.0; la skill es 1.9.0») y los títulos de los cambios del changelog que se aplicarían como contexto y, debajo, «Actualizar» / «Solo revisar» / «Ahora no»; se espera la respuesta en el chat.
  - «Actualizar» → seguir [`update-flow.md`](./update-flow.md).
  - «Solo revisar» → la revisión por diff de abajo; es también el respaldo cuando el changelog no cubre el salto.
  - «Ahora no» → seguir con la tarea y no volver a preguntar en esa sesión.

## Revisión (solo si el operador elige «Solo revisar»)

Comparar **solo** las partes que la plantilla controla, por rangos, sin leer todo:

- `rules.md`: las secciones «Reglas por defecto (fijas…)» y «Al cerrar una tarea (fijas…)» contra `template/agents/rules.md`. Se excluye la regla «Idioma de la documentación» (valor propio del proyecto).
- Multi-operador: además el bloque «Trabajo en paralelo» contra `template/multi/rules.md`.
- `AGENTS.md` y `CLAUDE.md` de la raíz: los bloques delimitados por `agent-context-skill:start/end` (o el prefijo anterior `agent-docs-skill:start/end`) contra `template/AGENTS.md` (o `template/multi/AGENTS.md`) y `template/CLAUDE.md`.

Mostrar cada diferencia al operador sin decidir cuál es «la correcta»: puede ser una edición intencional del proyecto.

## Qué se edita y qué no

Nada, salvo lo que el operador pida diferencia por diferencia; al terminar la revisión se pregunta en texto, como mensaje final del turno, con las diferencias encontradas como contexto, si actualizar el marcador, y solo con sí se reescribe la línea 1 de `rules.md`.

## Alcance

- Actualizar entre versiones es [`update-flow.md`](./update-flow.md); migrar documentación de otros sistemas es [`migration-flow.md`](./migration-flow.md).
- No compara `handoff.md`, `backlog.md` ni `history.md`: son contenido del proyecto.
