# migration-flow

Flujo que se dispara cuando, durante la detección automática de [`./questions-flow.md`](./questions-flow.md), se determina que el repo destino **ya tiene documentación de contexto para agentes, pero en un formato o convención distinto** al de este skill (no `docs/agents/` + `docs/project/`). En vez de tratarla como contenido ajeno y usar `agent-context/` como respaldo (el camino de «Carpeta destino» en [`questions-flow.md`](./questions-flow.md), para conflicto genuino), se **migra**: se lee el contenido real, se transforma para encajar en la estructura de este skill, reusando `template/` como formato de destino.

No inventa un flujo nuevo de scaffolding — una vez resuelta la migración, se apoya en `questions-flow.md` para completar lo que falte.

---

## Cuándo se dispara

Inmediatamente después del chequeo «ya existe» (Paso 1 de [`../SKILL.md`](../SKILL.md); el detalle está en «Prioridad», más abajo). Si se entra a este flujo desde `SKILL.md`, primero se resuelve «Idioma» de `questions-flow.md` para conocer `IDIOMA`:

- **Existen `docs/agents/` y/o `docs/project/`, con firma o marcador de versión** → flujo de proyecto existente normal (ya cubierto en `../SKILL.md`, no cambia nada acá). Si no tienen ni firma ni marcador, se pregunta (ver «Prioridad»).
- **No existen, pero la carpeta de documentación vieja tiene archivos cuyo nombre matchea el catálogo de este skill** (ver heurística abajo) en una proporción significativa → se dispara **este** flujo, en vez de continuar directo con `ALCANCE`. Hay proporción significativa si matchean **3 o más archivos** o **el 30 % o más** de los `.md` de la carpeta (cualquiera de los dos).
- **No existen y tampoco hay coincidencias** → sigue el flujo normal de `questions-flow.md` sin cambios (crear `docs/` nuevo, o usar `agent-context/` si hay conflicto real con contenido no relacionado — ver «Carpeta destino» en `questions-flow.md`).

**Dónde se busca documentación vieja** («la carpeta que cumpla ese rol»): `docs/`, `doc/` y `documentation/` (las que existan), más los archivos sueltos de la raíz con nombre de patrón de la heurística (`BACKLOG.md`, `HANDOFF.md`, `ROADMAP.md`, `CHANGELOG.md`, etc.). Se excluye `.claude/` (ahí viven skills y comandos). Los sueltos de la raíz cuentan para el umbral de 3 archivos, no para el porcentaje.

## Intención explícita del operador

Si el operador pide explícitamente migrar (ej. *"usa la skill agent-context-kit y migra mi proyecto"*, o cualquier variante que declare esa intención — ver la sección «Cuándo se dispara» de [`../SKILL.md`](../SKILL.md)), este flujo se dispara **sin depender de que la heurística encuentre una "proporción significativa" de coincidencias por sí sola.** La intención explícita reemplaza ese umbral.

- La heurística de nombres sigue corriendo igual: sirve para construir la tabla de mapeo propuesta, no para decidir si el flujo se dispara.
- Si no encuentra ningún archivo que matchee nada, no se asume en silencio que no hay nada para migrar: se muestra una tabla vacía (o con pocos matches) en la ronda de confirmación, y se pregunta explícitamente (abierta; candidatos: los archivos de la carpeta vieja sin match, o «Lo escribo yo» y «No aplica / omitir») qué archivos corresponde migrar a mano.
- Sin intención explícita, el umbral de "proporción significativa" sigue aplicando tal como se describe en "Cuándo se dispara" — evita que un `docs/` con un solo archivo de nombre coincidente por casualidad (ej. un `setup.md` genérico sin relación) dispare una migración completa que nadie pidió.

## Prioridad: firma de este skill sobre la heurística

**Chequeo «ya existe»** (lo usan el Paso 1 de [`../SKILL.md`](../SKILL.md) y [`questions-flow.md`](./questions-flow.md)): que exista `docs/agents/` y/o `docs/project/` (o su equivalente bajo `agent-context/`) no basta para decidir que es de esta skill. La carpeta debe ir acompañada de la firma o del marcador de versión (abajo).

- **Carpeta con firma o marcador** → es de esta skill: flujo de proyecto existente.
- **Carpeta sin firma ni marcador** → preguntar con `AskUserQuestion`, header `Origen`: «¿Esta documentación la generó esta skill?». «Sí» → flujo de proyecto existente, con [`version-check.md`](./version-check.md) tratando la versión como desconocida. «No» → este flujo.
- **Sin carpeta** → se sigue con «Cuándo se dispara».

Antes de aplicar la tabla de heurística, revisar si alguno de los archivos candidatos a `handoff.md` (cualquiera que matchee el patrón `handoff` en el nombre) contiene el comentario de firma `agent-context-kit:signature`. Se mira solo con `head -n 3`, sin abrir el archivo (ver `template/agents/handoff.md`).

- **Si la firma está presente** → este `docs/` ya fue generado por este mismo skill, no es un sistema distinto. No se dispara la migración: se trata como el flujo de proyecto existente de `../SKILL.md` (seguir el `AGENTS.md` del repo y ejecutar la tarea), aunque la estructura de carpetas no calce exactamente con `docs/agents/`+`docs/project/` (por ejemplo, si se movió o renombró algo a mano después de generarla). Si a ese `handoff.md`/`backlog.md` le faltan las anclas de sección, se agregan igual al actualizarlos (ver [`template-architecture.md`](./template-architecture.md), sección "Anclas de sección").
- **Si no está presente** → no descarta nada por sí solo — la firma es opcional (un `handoff.md` de este skill generado antes de que existiera esta firma, o editado a mano, puede no tenerla). Se sigue con la heurística de nombre normalmente.

La identidad «ya es de esta skill» también se decide por el marcador `agent-context-kit:version` en la línea 1 de un `rules.md` (`head -n 3`). Si el proyecto movió carpetas, `rules.md` se busca en la misma carpeta que el `handoff.md` firmado (o en su carpeta padre en multi-operador).

Si **cualquiera** de las dos señales (firma o marcador) está presente, **gana sobre la intención explícita de migrar**: se avisa al operador «este proyecto ya usa esta skill, no hay nada que migrar», se sigue el flujo de proyecto existente de `../SKILL.md` y se aplica [`version-check.md`](./version-check.md).

La firma es una señal de alta confianza cuando aparece, pero su ausencia es neutral, no una señal de "es de otro sistema".

## Heurística de detección y mapeo

Por cada archivo `.md` dentro de la carpeta de documentación vieja (recursivo, sin importar en qué subcarpeta esté) y por cada suelto de la raíz (ver «Dónde se busca»), comparar su nombre (normalizado: minúsculas, sin guiones/underscores) contra este catálogo — coincidencia por nombre exacto o por contener el término. El mapeo se arma **solo con nombres y tamaños** (`ls`, `wc -c`), sin abrir el contenido (política de lectura de [`../SKILL.md`](../SKILL.md)):

| Patrón en el nombre | Destino en este skill |
|---|---|
| `backlog` | `agents/backlog.md` |
| `changelog` / `history` | `agents/history.md` |
| `handoff` | `agents/handoff.md` |
| `roadmap` | `agents/roadmap.md` |
| `known-issues` / `issues` | `agents/known-issues.md` |
| `rules` / `conventions` / `guidelines` | `agents/rules.md` |
| `architecture` / `structure` | `project/architecture.md` |
| `stack` (ej. `stack-backend`, `tech-stack`) | `project/stack.md` |
| `entities` / `schema` / `data-model` / `database` | `project/entities.md` |
| `infrastructure` / `infra` / `deploy` | `project/infrastructure.md` |
| `decisions` / `adr` | `project/decisions.md` |
| `glossary` / `terms` | `project/glossary.md` |
| `testing` / `tests` | `project/testing.md` |
| `setup` / `getting-started` / `onboarding` | `project/setup.md` |
| `tiers` / `plans` (catálogo de planes) | `plans/tiers.md` |
| `costs` / `pricing` | `plans/costs.md` |
| `limits` / `quotas` / `rate-limits` | `plans/limits.md` |
| `payments` / `billing` | `plans/payments.md` |
| cualquier archivo dentro de una carpeta `external/` propia | `external/<mismo-nombre>.md` (ya es 1:1 con la convención de este skill, se mantiene el nombre) |
| `README.md` en la raíz de la carpeta vieja | no se migra 1:1 — se regenera en la Ronda final de `questions-flow.md`, como con cualquier scaffolding |

Si **dos o más archivos viejos matchean al mismo destino** (ej. `stack-backend.md` y `stack-frontend.md` apuntando ambos a `stack.md`), no se pisan entre sí: se fusionan en un único archivo destino conservando el contenido de ambos. La tabla de la ronda de confirmación muestra qué archivos se fusionan, y la fusión se pregunta aparte; no se asume en silencio.

Si un archivo **no matchea ningún patrón** → va a `docs/others/<subruta>/<nombre-original>.md`, sin transformar (ver "Contenido sin mapeo" más abajo).

## Precondición: git limpio

Definición única; la usan este flujo, [`multi-operator.md`](./multi-operator.md) («Pasar de plano a multi-operador») y [`update-flow.md`](./update-flow.md).

Verificar con `git status --porcelain` la carpeta de documentación (`docs/` o `agent-context/`; en una migración, también las otras carpetas de origen y los sueltos que matchearon), `AGENTS.md` y `CLAUDE.md`. Si hay cambios sin commitear, avisar que el original no tendría respaldo y pedir confirmación explícita (`AskUserQuestion`) o que se commiteen antes. Si el repo no es git, avisar que no habría cómo revertir y pedir confirmación.

## Ronda de confirmación (siempre, antes de tocar nada)

Antes de mover o escribir un solo archivo, mostrar al operador la tabla de mapeo propuesta completa (origen → destino, con tamaños), incluyendo qué archivos van a `docs/others/` por no tener match y cuáles quedarían fusionados (con sus orígenes). La tabla se muestra como texto (es contenido a revisar, no una pregunta). Las preguntas van después, en **dos tandas**: la de fusiones depende de las correcciones al mapeo, así que no puede ir junto a ellas (regla de preguntas independientes de [`asking-questions.md`](./asking-questions.md)). En cada tanda, una sola llamada de `AskUserQuestion` (máximo 4; regla general en [`../SKILL.md`](../SKILL.md#cómo-preguntarle-al-operador-obligatorio-al-aplicar-el-skill)), con la recomendada primero.

**Primera tanda** (independientes):

1. Header `Mapeo`: ¿la tabla de mapeo está bien, o hay que corregir algún archivo puntual? Opciones: «Está bien (Recomendado)» y «Corregir archivos» (cuáles, por «Otro»).
2. Header `Legacy`: **¿quieres conservar la documentación vieja en `docs-legacy/`?** Opciones: «Conservar (Recomendado)» y «No conservar». Si `docs-legacy/` ya existe (de una migración anterior), decirlo en la pregunta y ofrecer «Conservar la existente» (se conserva tal cual y no se crea otro respaldo) y «Reemplazarla».
3. Header `Texto`: **¿quieres condensar el texto para ahorrar tokens, o mantenerlo tal cual?** Opciones: «Mantener (Recomendado)» y «Condensar». Condensar = quitar relleno y repeticiones, enlazar en vez de duplicar y fusionar lo redundante, conservando todos los hechos, decisiones, fechas y números; mantener = no se reescribe el texto, solo se adapta a la estructura y las anclas de este skill. No se condensan las secciones fijas de la plantilla, la firma, las anclas ni el marcador de versión.

**Segunda tanda** (solo si, tras aplicar las correcciones de `Mapeo` y mostrar la tabla actualizada, quedan fusiones): header `Fusiones`: ¿corresponde fusionarlas tal cual, o deberían quedar separadas? Opciones: «Fusionar tal cual (Recomendado)» y «Dejarlas separadas». «Dejarlas separadas» = cada origen va a un destino propio (ej. `stack-backend.md` y `stack-frontend.md` quedan como archivos distintos, en la misma carpeta del destino original, `project/`).

Solo después de la confirmación se ejecuta la migración — nunca se mueve o transforma contenido en base a una heurística sin confirmar.

## Ejecución

1. **Resguardar el original, según la respuesta `Legacy`.**
   - **Conservar** → copiar a `docs-legacy/` en la raíz del repo destino **solo los archivos de la tabla confirmada** (los que matchean y los sin mapeo), no toda la carpeta (arrastraría documentación de usuario y otros archivos que no se migran). Con `cp --parents` desde la raíz del repo, que conserva la ruta relativa (ej. `docs-legacy/docs/claude/backlog.md`), sin modificarlos ni leerlos. Si `docs-legacy/` ya existía, solo se reemplaza si el operador lo eligió así; si no, queda como estaba y no se copia nada.
   - **No conservar** → no se crea `docs-legacy/`. Aplicar antes la [«Precondición: git limpio»](#precondición-git-limpio): el único respaldo del original es git.
2. **Migrar cada archivo mapeado, de a uno.** Por cada par (origen, destino confirmado): medir el origen (`wc -c`); leerlo (entero si pesa ≤ 8 KB, por trozos si pesa más: se procesa y se escribe cada trozo antes de leer el siguiente) y reescribirlo para que encaje en la plantilla correspondiente de `template/<categoría>/<archivo>.md`, con la estructura y convenciones de este skill. Se conserva toda la información del original: con "mantener" el texto no se reescribe; con "condensar" se aplica lo definido en la pregunta `Texto` (los hechos, decisiones, fechas y números no se pierden). La plantilla real de cada archivo define el formato esperado — incluidas, en `handoff.md` y `backlog.md`, las anclas de sección (`<!-- agent-context-kit:section=... -->`), que se insertan siempre aunque el original no tuviera nada equivalente (ver [`template-architecture.md`](./template-architecture.md), sección "Anclas de sección"). El `rules.md` resultante conserva siempre la línea 1 (marcador `agent-context-kit:version` con la versión actual de la skill; ver "Marcador de versión" en el mismo archivo) y las secciones fijas de la plantilla («Reglas por defecto» y «Al cerrar una tarea»); las reglas del `rules` viejo van a «Reglas específicas de este proyecto». El `handoff.md` conserva la firma. Los originales no se tocan hasta el paso 6.
3. **Contenido sin mapeo, tal cual y sin leerlo.** Cada archivo sin match va a `docs/others/<subruta>/<nombre-original>.md`, donde `<subruta>` es la ruta del origen dentro de su carpeta (así dos archivos con el mismo nombre no chocan; un suelto de la raíz va directo a `docs/others/`). Se coloca en el paso 6: `mv` (no `cp`) si el operador confirma retirar los originales; si no, `cp` y el original queda. `docs/others/` no tiene plantilla propia en `template/` — es una carpeta de resguardo para no perder contenido, no un catálogo curado como el resto de `docs/`.
4. **Completar lo que falte.** Seguir con el resto de `questions-flow.md` como si `ALCANCE = d` (desarrollo prolongado): lo que el `docs/` viejo no tenía (ej. si nunca existió un `rules.md`) se genera vacío/con placeholders igual que en cualquier scaffolding nuevo, y las Rondas 2-4 se preguntan igual para lo que no se pudo inferir del contenido migrado. En una migración, la Ronda 2 de `questions-flow.md` **no** reconstruye `history.md` desde `git log`: la primera entrada no es un volcado (ver el paso 7).
   - **Numeración del backlog:** si las tareas migradas a `backlog.md` no tienen número, numerarlas de arriba hacia abajo, dejar "Próximo número de tarea" en max+1 y anotar en el archivo "Numeración iniciada el <fecha>; las tareas cerradas antes (en `history.md`) no tienen número retroactivo". No se renumera `history.md` hacia atrás.
5. **Ronda final.** Igual que en `questions-flow.md`: generar `docs/README.md` (listando `others/` en el índice si va a existir, y `docs-legacy/` si se creó, con la nota «no leer: respaldo de la documentación anterior»), asegurar el puntero en `CLAUDE.md`/`AGENTS.md`. No se toca el bloque delimitado `agent-docs-skill` de esos archivos: se compara con la plantilla. Avisos:
   - Si el `AGENTS.md`/`CLAUDE.md` existente (fuera de ese bloque) apunta a rutas viejas, las de la documentación migrada, avisar al operador y ofrecer corregirlas. No se corrigen sin confirmar.
6. **Retirar los originales.** Con las copias verificadas (existen y no están vacías: `ls`, `wc -c`) y confirmación explícita del operador (`AskUserQuestion`, header `Originales`: «Retirar (Recomendado)» / «Dejarlos»), quitar de la carpeta vieja los originales ya migrados con `git rm`; si no es repo git, `rm` solo con esa confirmación. Se omite el original cuyo destino es su misma ruta. Los sin mapeo (paso 3) se mueven con `mv`/`git mv`. Con «Conservar» el respaldo ya está en `docs-legacy/`; con «No conservar», la pregunta avisa que el único respaldo es git.
7. **Dejar registro de la migración.** La primera entrada de `docs/agents/history.md` no queda vacía ni es un volcado de `git log`: se registra la migración en sí (como ✅ Hecha) — qué se migró y desde qué archivos (de `docs-legacy/` o del git si no se conservó), si se condensó o se mantuvo el texto, y qué quedó en `others/` sin mapear.

## Qué NO hace este flujo

- No borra `docs-legacy/` automáticamente. Si se conserva, queda como respaldo indefinido hasta que el operador decida borrarlo a mano — el flujo no vuelve a tocarlo después de crearlo.
- No retira los originales sin confirmación explícita.
- No lee el contenido de archivos para clasificarlos ni los que no tienen mapeo.
- No reformatea contenido dentro de `docs/others/` — ese contenido no se transforma, solo se resguarda para que no se pierda ni quede invisible.
- No decide fusiones ambiguas por su cuenta sin pasar por la ronda de confirmación.

---

Pasar de plano a multi-operador (el repo ya usa esta skill y se suma otra persona): [`multi-operator.md`](./multi-operator.md#pasar-de-plano-a-multi-operador).
