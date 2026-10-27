# migration-flow

Flujo para repos que ya tienen documentación de contexto para agentes en otro formato (no `docs/agents/` + `docs/project/`): se migra el contenido a la estructura de `template/` y [`./questions-flow.md`](./questions-flow.md) completa lo que falte.

---

## Cuándo se dispara

Inmediatamente después del chequeo «ya existe» (Paso 1 de [`../SKILL.md`](../SKILL.md); el detalle está en «Prioridad», más abajo). Si se entra a este flujo desde `SKILL.md`, primero se resuelve «Idioma» de `questions-flow.md` para conocer `IDIOMA`:

- **Existen `docs/agents/` y/o `docs/project/`, con firma o marcador de versión** → flujo de proyecto existente normal (ya cubierto en `../SKILL.md`, no cambia nada acá). Si no tienen ni firma ni marcador, se pregunta (ver «Prioridad»).
- **No existen, pero la carpeta de documentación vieja tiene archivos cuyo nombre matchea el catálogo de esta skill** (ver heurística abajo) en una proporción significativa → se dispara **este** flujo, en vez de continuar directo con `ALCANCE`. Hay proporción significativa si matchean **3 o más archivos** o **el 30 % o más** de los `.md` de la carpeta (cualquiera de los dos).
- **No existen y tampoco hay coincidencias** → sigue el flujo normal de `questions-flow.md` sin cambios (crear `docs/` nuevo, o usar `agent-context/` si hay conflicto real con contenido no relacionado — ver «Carpeta destino» en `questions-flow.md`).

**Dónde se busca documentación vieja** («la carpeta que cumpla ese rol»): `docs/`, `doc/` y `documentation/` (las que existan), más los archivos sueltos de la raíz con nombre de patrón de la heurística (`BACKLOG.md`, `HANDOFF.md`, `ROADMAP.md`, `CHANGELOG.md`, etc.). Se excluye `.claude/` (ahí viven skills y comandos). Los sueltos de la raíz cuentan para el umbral de 3 archivos, no para el porcentaje.

## Intención explícita del operador

Si el operador pide explícitamente migrar (ej. *"usa la skill agent-context-skill y migra mi proyecto"*), este flujo se dispara **sin depender del umbral de «Cuándo se dispara».**

- La heurística de nombres sigue corriendo igual: sirve para construir la tabla de mapeo propuesta, no para decidir si el flujo se dispara.
- Si no encuentra ningún archivo que matchee nada, no se asume en silencio que no hay nada para migrar: se muestra una tabla vacía (o con pocos matches) en la ronda de confirmación, y se pregunta explícitamente qué archivos corresponde migrar a mano, en texto como mensaje final del turno: la lista de archivos sin match como contexto y la pregunta debajo, esperando la respuesta en el chat (regla 5 de [`asking-questions.md`](./asking-questions.md)).
## Prioridad: firma de esta skill sobre la heurística

**Chequeo «ya existe»** (lo usan el Paso 1 de [`../SKILL.md`](../SKILL.md) y [`questions-flow.md`](./questions-flow.md)): que exista `docs/agents/` y/o `docs/project/` (o su equivalente bajo `agent-context/`) no basta para decidir que es de esta skill. La carpeta debe ir acompañada de la firma o del marcador de versión (abajo).

- **Carpeta con firma o marcador** → es de esta skill: flujo de proyecto existente.
- **Carpeta sin firma ni marcador** → preguntar con `AskUserQuestion`, header `Origen`, con el enunciado «¿Esta documentación la generó esta skill? (Se revisó `<carpeta>`: sin firma ni marcador.)». «Sí» → flujo de proyecto existente, con [`version-check.md`](./version-check.md) tratando la versión como desconocida. «No» → este flujo.
- **Sin carpeta** → se sigue con «Cuándo se dispara».

Antes de aplicar la tabla de heurística, revisar si alguno de los archivos candidatos a `handoff.md` (cualquiera que matchee el patrón `handoff` en el nombre) contiene el comentario de firma `agent-context-skill:signature` (o `agent-context-kit:signature`, el prefijo anterior). Se mira solo con `head -n 3`, sin abrir el archivo (ver `template/agents/handoff.md`).

- **Si la firma está presente** → este `docs/` ya fue generado por este mismo skill, no es un sistema distinto. No se dispara la migración: se trata como el flujo de proyecto existente de `../SKILL.md` (seguir el `AGENTS.md` del repo y ejecutar la tarea), aunque la estructura de carpetas no calce exactamente con `docs/agents/`+`docs/project/` (por ejemplo, si se movió o renombró algo a mano después de generarla). Si a ese `handoff.md`/`backlog.md` le faltan las anclas de sección, se agregan igual al actualizarlos (ver [`template-architecture.md`](./template-architecture.md), sección "Anclas de sección").
- **Si no está presente** → no descarta nada por sí solo — la firma es opcional (un `handoff.md` de esta skill generado antes de que existiera esta firma, o editado a mano, puede no tenerla). Se sigue con la heurística de nombre normalmente.

La identidad «ya es de esta skill» también se decide por el marcador `agent-context-skill:version` (o `agent-context-kit:version`, el prefijo anterior) en la línea 1 de un `rules.md` (`head -n 3`). Si el proyecto movió carpetas, `rules.md` se busca en la misma carpeta que el `handoff.md` firmado (o en su carpeta padre en multi-operador).

Si **cualquiera** de las dos señales (firma o marcador) está presente, **gana sobre la intención explícita de migrar**: se avisa al operador «este proyecto ya usa esta skill, no hay nada que migrar», se sigue el flujo de proyecto existente de `../SKILL.md` y se aplica [`version-check.md`](./version-check.md).
## Heurística de detección y mapeo

Por cada archivo `.md` dentro de la carpeta de documentación vieja (recursivo, sin importar en qué subcarpeta esté) y por cada suelto de la raíz (ver «Dónde se busca»), comparar su nombre (normalizado: minúsculas, sin guiones/underscores) contra este catálogo — coincidencia por nombre exacto o por contener el término. El mapeo se arma **solo con nombres y tamaños** (`ls`, `wc -c`), sin abrir el contenido (política de lectura de [`../SKILL.md`](../SKILL.md)):

| Patrón en el nombre | Destino en esta skill |
|---|---|
| `backlog` | `agents/backlog.md` |
| `changelog` / `history` | `agents/history.md` |
| `handoff` | `agents/handoff.md` |
| `roadmap` | `agents/roadmap.md` |
| `known-issues` / `issues` | `agents/known-issues.md` |
| `rules` / `conventions` / `guidelines` | `agents/rules.md` |
| `architecture` / `structure` | `project/architecture.md` |
| `stack` (ej. `stack-backend`, `tech-stack`) | `project/decisions/stack.md` |
| `entities` / `schema` / `data-model` / `database` | `project/entities.md` |
| `infrastructure` / `infra` / `deploy` | `project/infrastructure.md` |
| `decisions` / `adr` | `project/decisions/<tema>.md` (un tema por archivo viejo; `general.md` si es uno solo) |
| `glossary` / `terms` | `project/glossary.md` |
| `testing` / `tests` | `project/testing.md` |
| `setup` / `getting-started` / `onboarding` | `project/setup.md` |
| `tiers` / `plans` (catálogo de planes) | `plans/tiers.md` |
| `costs` / `pricing` | `plans/costs.md` |
| `limits` / `quotas` / `rate-limits` | `plans/limits.md` |
| `payments` / `billing` | `plans/payments.md` |
| cualquier archivo dentro de una carpeta `external/` propia | `external/<mismo-nombre>.md` (ya es 1:1 con la convención de esta skill, se mantiene el nombre) |
| `README.md` en la raíz de la carpeta vieja | no se migra 1:1 — se regenera en la Ronda final de `questions-flow.md`, como con cualquier scaffolding |

Si **dos o más archivos viejos matchean al mismo destino** (ej. `stack-backend.md` y `stack-frontend.md` apuntando ambos a `decisions/stack.md`), no se pisan entre sí: se fusionan en un único archivo destino conservando el contenido de ambos. La tabla de la ronda de confirmación muestra qué archivos se fusionan, y la fusión se pregunta aparte; no se asume en silencio.

Si un archivo **no matchea ningún patrón** → va a `docs/others/<subruta>/<nombre-original>.md`, sin transformar (ver "Contenido sin mapeo" más abajo).

## Precondición: git limpio

Verificar con `git status --porcelain` la carpeta de documentación (`docs/` o `agent-context/`; en una migración, también las otras carpetas de origen y los sueltos que matchearon), `AGENTS.md` y `CLAUDE.md`. Si hay cambios sin commitear, preguntar en texto como mensaje final del turno: la salida de `git status --short` como contexto, el aviso de que el original no tendría respaldo y, debajo, la petición de confirmación explícita o de que se commiteen antes; se espera la respuesta en el chat (regla 5 de [`asking-questions.md`](./asking-questions.md)). Si el repo no es git, avisar que no habría cómo revertir y pedir confirmación con el recuadro (`AskUserQuestion`), porque se entiende sola.

## Ronda de confirmación (siempre, antes de tocar nada)

Antes de mover o escribir un solo archivo, mostrar al operador la tabla de mapeo propuesta completa (origen → destino, con tamaños), incluyendo qué archivos van a `docs/others/` por no tener match y cuáles quedarían fusionados (con sus orígenes). La tabla se muestra como texto (es contenido a revisar), así que las preguntas `Mapeo`, `Legacy` y `Texto` se responden en texto, numeradas y cortas, dentro de ese mismo mensaje, que cierra el turno; no se usa el recuadro ([`asking-questions.md`](./asking-questions.md), regla 5). Las preguntas van en **dos rondas**: la primera, en texto con la tabla; la segunda, la de fusiones, en texto aparte, porque depende de las correcciones al mapeo.

**Primera ronda** (en texto, con la tabla; independientes):

1. **Pregunta (Mapeo):** ¿la tabla de mapeo está bien, o hay que corregir algún archivo puntual? Opciones: «Está bien (Recomendado)» y «Corregir archivos» (cuáles, en la misma respuesta).
2. **Pregunta (Legacy):** ¿quieres conservar la documentación vieja en `docs-legacy/`? Opciones: «Conservar (Recomendado)» y «No conservar». Si `docs-legacy/` ya existe (de una migración anterior), decirlo en la pregunta y ofrecer «Conservar la existente» (se conserva tal cual y no se crea otro respaldo) y «Reemplazarla».
3. **Pregunta (Texto):** ¿quieres condensar el texto para ahorrar tokens, o mantenerlo tal cual? Opciones: «Mantener (Recomendado)» y «Condensar» (definido en Ejecución, paso 2).

**Segunda ronda** (en texto, solo si, tras aplicar las correcciones de `Mapeo`, quedan fusiones; mensaje final con la lista de fusiones propuestas y la tabla actualizada como contexto, y la pregunta debajo): **Pregunta (Fusiones):** ¿corresponde fusionarlas tal cual, o deberían quedar separadas? Opciones: «Fusionar tal cual (Recomendado)» y «Dejarlas separadas». «Dejarlas separadas» = cada origen va a un destino propio (ej. `stack-backend.md` y `stack-frontend.md` quedan como archivos distintos, en la misma carpeta del destino original (`project/`, o `project/decisions/` para `stack-*`)).

Solo después de la confirmación se ejecuta la migración — nunca se mueve o transforma contenido en base a una heurística sin confirmar.

## Ejecución

1. **Resguardar el original, según la respuesta `Legacy`.**
   - **Conservar** → copiar a `docs-legacy/` en la raíz del repo destino **solo los archivos de la tabla confirmada** (los que matchean y los sin mapeo), no toda la carpeta (arrastraría documentación de usuario y otros archivos que no se migran). Con `cp --parents` desde la raíz del repo, que conserva la ruta relativa (ej. `docs-legacy/docs/claude/backlog.md`), sin modificarlos ni leerlos. Si `docs-legacy/` ya existía, solo se reemplaza si el operador lo eligió así; si no, queda como estaba y no se copia nada.
   - **No conservar** → no se crea `docs-legacy/`. Aplicar antes la [«Precondición: git limpio»](#precondición-git-limpio): el único respaldo del original es git.
2. **Migrar cada archivo mapeado, de a uno.** Por cada par (origen, destino confirmado): medir el origen (`wc -c`); leerlo (entero si pesa ≤ 8 KB, por trozos si pesa más: se procesa y se escribe cada trozo antes de leer el siguiente) y reescribirlo para que encaje en la plantilla correspondiente de `template/<categoría>/<archivo>.md`, con la estructura y convenciones de esta skill. Se conserva toda la información del original. «Mantener» = el texto no se reescribe, solo se adapta a la estructura y las anclas de esta skill. «Condensar» = quitar relleno y repeticiones, enlazar en vez de duplicar y fusionar lo redundante, conservando todos los hechos, decisiones, fechas y números; no se condensan las secciones fijas de la plantilla, la firma, las anclas ni el marcador de versión. La plantilla real de cada archivo define el formato esperado — incluidas, en `handoff.md` y `backlog.md`, las anclas de sección (`<!-- agent-context-skill:section=... -->`), que se insertan siempre aunque el original no tuviera nada equivalente (ver [`template-architecture.md`](./template-architecture.md), sección "Anclas de sección"). El `rules.md` resultante conserva siempre la línea 1 (marcador `agent-context-skill:version` con la versión actual de la skill; ver "Marcador de versión" en el mismo archivo) y las secciones fijas de la plantilla («Reglas por defecto» y «Al cerrar una tarea»); las reglas del `rules` viejo van a «Reglas específicas de este proyecto». El `handoff.md` conserva la firma. Los originales no se tocan hasta el paso 6. Lo que se reescribe es solo el contenido del proyecto migrado; las secciones fijas de la plantilla (todo lo que no es contenido propio del proyecto: encabezados, textos de instrucciones, formato de tareas, anclas, firma, marcador) se copian de la plantilla literalmente, aun en «Condensar», y el contenido migrado se inserta en los huecos de esa copia.
3. **Contenido sin mapeo, tal cual y sin leerlo.** Cada archivo sin match va a `docs/others/<subruta>/<nombre-original>.md`, donde `<subruta>` es la ruta del origen dentro de su carpeta (así dos archivos con el mismo nombre no chocan; un suelto de la raíz va directo a `docs/others/`). Se coloca en el paso 6: `mv` (no `cp`) si el operador confirma retirar los originales; si no, `cp` y el original queda. `docs/others/` no tiene plantilla propia en `template/` — es una carpeta de resguardo para no perder contenido, no un catálogo curado como el resto de `docs/`.
4. **Completar lo que falte.** Seguir con el resto de `questions-flow.md` como si `ALCANCE = d` (desarrollo prolongado), con una excepción: `agents/roadmap.md` no se genera por `ETAPA` sino solo si la documentación vieja tenía uno (el mapeo `roadmap` de la tabla; así el resultado no depende de la etapa que se infiera cuando no se puede preguntar): lo que el `docs/` viejo no tenía (ej. si nunca existió un `rules.md`) se genera vacío/con placeholders igual que en cualquier scaffolding nuevo, y las Rondas 2-4 se preguntan igual para lo que no se pudo inferir del contenido migrado. En una migración, la Ronda 2 de `questions-flow.md` **no** reconstruye `history.md` desde `git log`: la primera entrada no es un volcado (ver el paso 7). El «Cierre» de `questions-flow.md` no se aplica aquí: la recomendación de la suite se da en el paso 8.
   - **Numeración del backlog:** si las tareas migradas a `backlog.md` no tienen número, numerarlas de arriba hacia abajo, dejar "Próximo número de tarea" en max+1 y anotar en el archivo "Numeración iniciada el <fecha>; las tareas cerradas antes (en `history.md`) no tienen número retroactivo". No se renumera `history.md` hacia atrás.
5. **Ronda final.** Igual que en `questions-flow.md`: generar `docs/README.md` (listando `others/` en el índice si va a existir, y `docs-legacy/` si se creó, con la nota «no leer: respaldo de la documentación anterior»), asegurar el puntero en `CLAUDE.md`/`AGENTS.md`. No se toca el bloque delimitado `agent-context-skill:` de esos archivos: se compara con la plantilla. Avisos:
   - Si el `AGENTS.md`/`CLAUDE.md` existente (fuera de ese bloque) apunta a rutas viejas, las de la documentación migrada, mostrar las rutas afectadas y preguntar si se corrigen, en texto como mensaje final del turno (regla 5 de [`asking-questions.md`](./asking-questions.md)). No se corrigen sin confirmar.
6. **Retirar los originales.** Con las copias verificadas (existen y no están vacías: `ls`, `wc -c`) y confirmación explícita del operador (pregunta en texto como mensaje final del turno: la lista de las copias verificadas con sus tamaños de `wc -c` como contexto y, debajo, **Pregunta (Originales):** «Retirar (Recomendado)» / «Dejarlos»; se espera la respuesta en el chat), quitar de la carpeta vieja los originales ya migrados con `git rm`; si no es repo git, `rm` solo con esa confirmación. Se omite el original cuyo destino es su misma ruta. Los sin mapeo (paso 3) se mueven con `mv`/`git mv`. Con «Conservar» el respaldo ya está en `docs-legacy/`; con «No conservar», la pregunta avisa que el único respaldo es git.
7. **Dejar registro de la migración.** La primera entrada de `docs/agents/history.md` no queda vacía ni es un volcado de `git log`: se registra la migración en sí (como ✅ Hecha) — qué se migró y desde qué archivos (de `docs-legacy/` o del git si no se conservó), si se condensó o se mantuvo el texto, y qué quedó en `others/` sin mapear.
8. **Oferta de la suite (siempre se da).** Al terminar la migración, el mensaje de cierre lleva siempre la recomendación de [`suite-recommendation.md`](./suite-recommendation.md). No es un paso de la migración: es un aviso que se da una vez, y lo opcional es que el operador lo acepte.

## Qué NO hace este flujo

- Nunca retira los originales sin confirmación explícita (paso 6) ni borra `docs-legacy/`: si se conserva, queda como respaldo hasta que el operador lo borre a mano, y el flujo no vuelve a tocarlo después de crearlo.
- No instala ni ejecuta nada de la suite: la recomendación del paso 8 solo la ofrece; instalar o ejecutar algo depende de que el operador la acepte.
- Lo demás (no leer para clasificar, `docs/others/` sin transformar, fusiones solo con confirmación) ya está en la heurística, la ronda de confirmación y el paso 3.

---

Pasar de plano a multi-operador (el repo ya usa esta skill y se suma otra persona): [`multi-operator.md`](./multi-operator.md#pasar-de-plano-a-multi-operador).
