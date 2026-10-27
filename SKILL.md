---
name: agent-context-skill
description: Genera o actualiza la documentación de contexto de un proyecto (reglas, estado en caliente, backlog, historial, arquitectura, stack, integraciones externas) para que cualquier agente de IA sepa en qué momento está el proyecto sin depender de la memoria de una conversación. Úsalo al empezar a trabajar en un repositorio — para inicializar esta documentación si no existe, o para leerla y mantenerla al día si ya existe.
---

# agent-context-skill

Versión de esta skill: **2.3.0**

## Cuándo se dispara

Al empezar a trabajar en un repositorio, antes de tocar código. También se invoca explícitamente; pedir migrar (ej. *"...y migra mi proyecto"*) fuerza el chequeo de [`docs/migration-flow.md`](./docs/migration-flow.md) aunque la heurística no halle suficientes coincidencias.

## Política de lectura (obligatoria al aplicar la skill)

Se aplica una vez por repo; después el `AGENTS.md` del repo guía al agente. Rige también en los flujos que enlaza: si un paso la contradice, gana ella.

1. Leer solo lo que el paso actual necesita.
2. Medir con `wc -c`: entero solo si ≤ 8 KB o lo manda el flujo; si no, `grep -n` o `offset`/`limit`.
3. Clasificar con `ls`, `wc -c` y `head`, sin abrir el contenido.
4. Mover o copiar con el comando nativo del shell (`cp`/`mv`, o `Copy-Item`/`Move-Item` en PowerShell) o con la herramienta de archivos, nunca leyendo y reescribiendo; leer solo para transformar.
5. De a uno, sin acarrear ni releer: procesar, escribir, pasar al siguiente.

## Cómo preguntarle al operador (obligatorio al aplicar la skill)

Toda pregunta al operador se hace con `AskUserQuestion` (recuadro), también las abiertas, salvo las que necesitan que el operador revise contenido (plan, tabla, lista, diff): esas van en texto, con el contexto completo, como mensaje final del turno (regla 5). Reglas: [`docs/asking-questions.md`](./docs/asking-questions.md).

## Paso 1 — ¿Ya existe documentación de esta skill?

Revisar si el repo destino tiene `docs/agents/` y/o `docs/project/` (o bajo `agent-context/`) con firma o marcador de versión de la skill (sin ninguno: «Prioridad» de [`docs/migration-flow.md`](./docs/migration-flow.md)).

### Si existe → no hay nada que generar

Antes de la tarea, seguir [`docs/version-check.md`](./docs/version-check.md) (versión de la skill; `head -n 3` del `rules.md`); ese archivo también ofrece renombrar los marcadores heredados (`agent-context-kit:`/`agent-docs-skill:`). Luego, seguir el `AGENTS.md` del repo (qué leer y en qué orden; el idioma está en `rules.md`, no se pregunta) y ejecutar la tarea pedida. Si se suma otra persona y el operador pide multi-operador, abrir [`docs/multi-operator.md`](./docs/multi-operator.md), sección "Pasar de plano a multi-operador". Si a `handoff.md`/`backlog.md` les faltan las anclas de sección (`<!-- agent-context-skill:section=... -->`), agregarlas; ver [`docs/template-architecture.md`](./docs/template-architecture.md), "Anclas de sección". No seguir con el árbol de preguntas.

### Si no existe → abrir el flujo que corresponda

- **Hay documentación de contexto previa en otro formato** (ej. un `docs/claude/` con su propio `backlog.md`/`handoff.md`) → [`docs/migration-flow.md`](./docs/migration-flow.md): reutiliza ese contenido en vez de perderlo.
- **No hay nada reconocible para migrar** → [`docs/questions-flow.md`](./docs/questions-flow.md): árbol de preguntas (idioma, alcance de la tarea, etapa del proyecto) que decide qué generar copiando solo lo que corresponda desde `template/`, nunca el catálogo completo, y asegura el puntero en `CLAUDE.md` y `AGENTS.md` de la raíz.

## Dónde está cada cosa

- **Qué preguntar y qué copiar** → [`docs/questions-flow.md`](./docs/questions-flow.md)
- **Migración desde otro sistema de documentación** → [`docs/migration-flow.md`](./docs/migration-flow.md)
- **Varias personas trabajando en paralelo (modo multi-operador, opcional)** → [`docs/multi-operator.md`](./docs/multi-operator.md); solo se abre si el operador lo activa
- **Catálogo de plantillas y para qué sirve cada una** → [`docs/template-architecture.md`](./docs/template-architecture.md); plantillas en [`template/`](./template/)
- **Detección `docs/` vs. `agent-context/` y archivos puntero `CLAUDE.md`/`AGENTS.md`** → «Carpeta destino» y Ronda final de [`docs/questions-flow.md`](./docs/questions-flow.md)
