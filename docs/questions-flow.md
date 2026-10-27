# questions-flow

Árbol de decisión que el agente sigue al ejecutar esta skill sobre un repositorio: qué preguntar, cómo interpretar la respuesta y qué archivo copiar de `template/` a `docs/<destino>/` (o qué leer/actualizar).

Este archivo se abre solo cuando **no** existe documentación de esta skill en el repo destino: el caso "ya existe" se resuelve en [`../SKILL.md`](../SKILL.md), sin pasar por acá.

**Cómo se pregunta:** según [`asking-questions.md`](./asking-questions.md). Acá cada pregunta se escribe como `header` (≤12 caracteres) + opciones, con la recomendada primero. Las preguntas de las rondas van con el recuadro; si una necesita que el operador revise contenido, va en texto (regla 5 de [`asking-questions.md`](./asking-questions.md)).

Rige la política de lectura de [`../SKILL.md`](../SKILL.md): de `template/` se lee solo cada plantilla que se va a completar, y lo que se copia sin cambios (`CLAUDE.md`, `external/_example-service.md`) se copia con el comando nativo del shell, sin leerlo.

Convención de rutas: `template/X` se refiere a la plantilla en esta skill; `docs/X` se refiere al destino en el repo del operador (o `agent-context/X` si aplica el conflicto descrito en «Carpeta destino» más abajo).

## Carpeta destino: `docs/` o `agent-context/`

Se decide mirando el repo destino, en este orden:

1. **Existe `docs/agents/` o `docs/project/`, con la firma o el marcador de versión de la skill** → la skill ya se inicializó acá: no se repite el scaffolding, se sigue el flujo de proyecto existente (ver [`../SKILL.md`](../SKILL.md), Paso 1). Sin firma ni marcador, ver «Prioridad» en [`migration-flow.md`](./migration-flow.md).
2. **Existe `docs/` pero sin esas subcarpetas** (documentación de otra naturaleza: guía de usuario, Docusaurus, etc.) → **conflicto**: no se toca esa carpeta y se usa `agent-context/` en la raíz como respaldo.
3. **No existe `docs/`** → se crea `docs/` con la estructura del catálogo.

El puntero en la raíz (`AGENTS.md`/`CLAUDE.md`) deja explícito cuál se usó; ver la Ronda final.

**Convención de interacción — rondas:** las preguntas se agrupan en rondas. Dentro de una misma ronda las preguntas son independientes entre sí (ninguna depende de la respuesta de otra de la misma ronda), así que se hacen juntas en una llamada a `AskUserQuestion` (tandas de hasta 4, ver [`asking-questions.md`](./asking-questions.md)). Solo se avanza a la siguiente ronda una vez respondida la anterior, porque su resultado puede condicionar qué se pregunta después.

---

## Idioma de la documentación (siempre, antes que cualquier otra cosa)

Corre primero, antes de la Ronda 1, porque determina en qué idioma se redacta todo lo que sigue.

1. **¿`docs/agents/rules.md` ya existe y tiene el idioma registrado?** (ver la regla "Idioma de la documentación" en sus Reglas por defecto — `template/agents/rules.md`).
   - **Sí** → usar ese valor como `IDIOMA`. No volver a preguntar. Fin de este paso.
   - **No** → seguir con el paso 2.
2. **Detectar `IDIOMA` a partir del texto del operador disponible en la conversación actual.** Es común que sea un chat nuevo sin más historial que la frase de invocación misma (ej. *"usa la skill agent-context-skill"*) — no asumir que hay más contexto disponible del que realmente hay.
   - Si ese texto tiene suficientes marcas de idioma natural → usar ese idioma como `IDIOMA`.
   - Si es ambiguo o insuficiente (ej. el operador solo escribió *"skill agent-context-skill"*, sin palabras de idioma natural que lo identifiquen) → preguntar explícitamente, **en inglés** (idioma universal, para no asumir uno), con `AskUserQuestion`: pregunta *"Which language should I use for this project's documentation?"*, header `Language`, opciones `Español (Recomendado)` y `English` (otros idiomas, por «Otro»)
3. **De acá en adelante, redactar todo contenido nuevo (prosa y headers de sección) en `IDIOMA`**, con estas excepciones que se mantienen siempre en inglés:
   - Nombres de archivo y carpetas del catálogo (`backlog.md`, `handoff.md`, `stack.md`, etc.).
   - Términos propios de esta skill (ej. "Handoff", "Backlog", "History", "Roadmap", "Placeholder") y jerga técnica sin traducción natural asentada (ej. "linter", "commit", "deploy", "merge").
4. **Si en esta ejecución se genera o se toca `docs/agents/rules.md`, registrar `IDIOMA`** en la regla correspondiente, para que sesiones futuras no vuelvan a preguntarlo.

---

## Ronda 1 — Gate de alcance (siempre, sola)

**Preguntar** (una sola pregunta, header `Alcance`; sin «(Recomendado)», porque depende solo de lo que el operador quiera): "¿Qué deseas hacer?"

- **a) Tarea puntual** (bug fix, ajuste menor)
- **b) Agregar una feature** a un proyecto existente
- **c) Testear/validar algo puntual**
- **d) Iniciar o continuar un desarrollo prolongado**

Guardar la respuesta como `ALCANCE`.

---

## Detección automática (sin preguntar, corre después de la Ronda 1)

El agente ya revisó en [`../SKILL.md`](../SKILL.md) (paso 1) si existe `docs/agents/` y/o `docs/project/` (o sus equivalentes bajo `agent-context/`) con la firma o el marcador de versión de la skill (detalle en «Prioridad» de [`migration-flow.md`](./migration-flow.md)); si existen, el flujo terminó allá. Acá solo se llega si **no** existen. Falta distinguir:

- **No existen, pero la documentación vieja tiene archivos cuyo nombre matchea el catálogo de esta skill en proporción significativa (carpetas y umbral en [«Cuándo se dispara»](./migration-flow.md#cuándo-se-dispara))** → hay documentación de contexto previa, pero de otro formato/convención. No se trata como conflicto genuino (eso sería `agent-context/`, ver «Carpeta destino» más arriba): se dispara el **flujo de migración** — ver [`./migration-flow.md`](./migration-flow.md). `ALCANCE` deja de ser relevante hasta que ese flujo termine (internamente se comporta como `ALCANCE = d`).

- **NO** → no hay documentación previa de esta skill ni nada reconocible para migrar. Continuar según `ALCANCE`:

  | ALCANCE | Set | Continúa a |
  |---|---|---|
  | a) tarea puntual | Mínimo | Copiar el set mínimo (ver tabla de sets más abajo) y saltar a la **Ronda final (con opt-in)** |
  | c) testear puntual | Mínimo | Igual que (a) |
  | b) agregar feature | Intermedio | Copiar el set intermedio (`decisions/stack.md` se redacta con lo que se detecte en el repo, o queda en «Stack por definir»); evaluar Ronda 3 solo si la feature toca esa área (glossary, external, infra, entities, testing, setup), salvo la pregunta de varias personas, que se hace siempre; luego **Ronda final** (sin opt-in, ya se decidió documentar) |
  | d) desarrollo prolongado | Completo | Ir a **Ronda 2** |

---

## Ronda 2 — Contexto base (solo si `ALCANCE = d`)

La evidencia que respalda las recomendadas (historial de `git log`, archivos de dependencias, releases o deploy detectados) va en una línea, en la descripción de la opción recomendada o en el enunciado, sin mensaje previo. Preguntar las 4 juntas, en una sola llamada a `AskUserQuestion` (son independientes):

1. **Header `Proyecto`: ¿es un proyecto nuevo o uno existente al que se le agrega documentación retroactiva?** Opciones «Existente» y «Nuevo»; la recomendada es la que indique `git log` (con historial, «Existente»).
   - Si es **existente** → con 2 o más commits, revisar el historial de git (`git log --oneline`, sin diffs) para reconstruir un `agents/history.md` inicial en vez de dejarlo vacío. Extraer hitos relevantes de los commits, no un volcado literal del log (todas las entradas reconstruidas así van como ✅ Hecha). Con 1 o ninguno, se trata como «nuevo».
   - Si es **nuevo** → `agents/history.md` queda con la plantilla base y la línea «Sin tareas cerradas todavía.».

2. **Header `Etapa`: ¿en qué etapa está el proyecto?** (recomendada: la que sugiera el repo, ej. releases o deploy configurado apuntan a producción) → guardar como `ETAPA`:
   - `idea/setup`
   - `desarrollo activo (MVP)`
   - `producción/mantenimiento`

3. **Header `Tipo`: ¿qué tipo de proyecto es?** (recomendada: la que indique lo detectado en el repo; `otro` se cubre con «Otro», porque la herramienta admite 4 opciones) → informativo, para redactar `project/architecture.md` y `project/decisions/stack.md` con el enfoque correcto:
   - `frontend`
   - `backend`
   - `fullstack (repo único)`
   - `fullstack (monorepo)`
   - `otro`

4. **Header `Stack`: ¿ya está definido el stack del proyecto?** (recomendada: «Está en el repo» si hay archivos de dependencias; «Por definir» en un proyecto nuevo sin ellos) → llena `project/decisions/stack.md`:
   - «Está en el repo» → se registran solo las decisiones no obvias (qué NO usar, por qué se eligió algo), no el inventario de dependencias.
   - «Otro» → el operador escribe el stack acordado; cada pieza queda como `acordado` (o `instalado` si ya está en el repo).
   - «Por definir» → `stack.md` queda con la línea «Stack por definir: al elegirlo, registrarlo acá».

---

## Al copiar una plantilla al repo destino (aplica a todas las rondas)

Copia literal: primero se copia el archivo entero de `template/` al destino con el comando nativo del shell (o la herramienta de archivos) y después se edita con `Edit` solo lo que los pasos siguientes indican (`[Placeholder]` y comentarios de guía). Todo lo demás queda literal, carácter por carácter: no resumir, parafrasear, reordenar, «limpiar» ni agregar texto, tampoco las secciones fijas de `handoff.md`, `backlog.md`, `history.md`, `rules.md`, `roadmap.md` ni `decisions/stack.md`.

1. Reemplazar los `[Placeholder]` por contenido real (o por la frase alternativa que la propia plantilla sugiere, ej. "Ninguna"). Si no hay contenido y la plantilla no trae frase alternativa propia, la frase es siempre «Ninguna registrada todavía.» (con punto final), la misma en todos los archivos.
2. **Quitar los comentarios HTML de guía** (`<!-- ... -->`), salvo la firma `agent-context-skill:signature`, las anclas `agent-context-skill:section=...`, el marcador `agent-context-skill:version` (línea 1 de `rules.md`) y los marcadores `agent-context-skill:start/end`. Excepción: `external/_example-service.md` se copia sin modificar, con el comando nativo del shell (Ronda 4). Al terminar, comprobar con `grep -n "<!--"` que en el archivo solo quedan esos comentarios de máquina; los demás se quitan, incluidos los que dicen «no se copia literal» o «quitar esta guía».
3. En el set mínimo (sin `docs/README.md`), agregar al inicio de `rules.md` (después del marcador de versión de la línea 1) la definición de "operador" que lleva el `README.md`: *"**Operador:** la persona dueña del proyecto que le pide tareas al agente, aprueba decisiones y a quien se le pregunta cuando algo no está definido."*
4. **Sin contenido real, sin inventar:** en las plantillas cuyo cuerpo son ejemplos (`roadmap.md`, `known-issues.md`), si el operador no dio contenido, se conservan el título y la introducción y se agrega una línea («Sin … registrados todavía»); no se inventan bloques de ejemplo ni se dejan los de la plantilla.
5. Escribir solo lo que aporta al agente: no volcar listas de dependencias ni módulos uno por uno; sí convenciones, decisiones y restricciones y, en `architecture.md`, el árbol anotado de los niveles superiores del código (una línea de propósito por entrada). Lo que ya vive en otro archivo se enlaza, no se repite.
6. **Enlaces a archivos que no se generan:** la línea de `rules.md` «Bugs conocidos / zonas frágiles → ./known-issues.md» (sección «Enlaces») se conserva solo si `agents/known-issues.md` se copia; si no, se quita esa línea.
7. **Título e introducción siempre:** `decisions/stack.md` conserva su título, su introducción y el separador `---`, también con «Stack por definir» (esa línea va después del separador); `decisions/README.md`, su título, su introducción y sus secciones fijas. Solo el bloque `## [Placeholder — pieza]` se repite por pieza o se reemplaza por la línea «Stack por definir».

---

## Archivos siempre copiados (sin preguntar, corre después de la Ronda 2)

Cuando `ALCANCE = d`, copiar siempre:

- `template/agents/rules.md` → `docs/agents/rules.md` (conserva su línea 1: el marcador de versión de la skill ya viene en la plantilla)
- `template/agents/handoff.md` → `docs/agents/handoff.md`
- `template/agents/backlog.md` → `docs/agents/backlog.md`
- `template/agents/history.md` → `docs/agents/history.md`
- `template/project/architecture.md` → `docs/project/architecture.md`
- `template/project/decisions/README.md` → `docs/project/decisions/README.md` (el índice)
- `template/project/decisions/stack.md` → `docs/project/decisions/stack.md`, con lo que respondió `Stack` (Ronda 2); sin stack definido queda en la línea «Stack por definir»

Y según `ETAPA` (sin preguntar):

- **`ETAPA` ≠ `idea/setup`** → copiar también `template/agents/roadmap.md` → `docs/agents/roadmap.md`. En una migración no rige: el roadmap se genera solo si la documentación vieja tenía uno ([`migration-flow.md`](./migration-flow.md), «Ejecución», paso 4).

Los otros temas de `docs/project/decisions/` no se copian vacíos: se crean cuando hay una decisión firme que registrar (ver su `README.md`).

`docs/README.md` **no se copia acá.** Su contenido varía según el set y las respuestas de cada ronda (qué archivos terminaron existiendo), así que se genera al final del flujo (ver Ronda final, paso 1) usando `template/README.md` solo como guía de estructura/formato, no como fuente literal.

---

## Ronda 3 — Preguntas condicionadas (solo si `ALCANCE = d`, con `ETAPA` ya conocida)

Todas son independientes entre sí (solo dependen de `ETAPA`, que ya se conoce de la Ronda 2), así que se preguntan con `AskUserQuestion` en llamadas de hasta 4: llamada 1 = multi-operador, glosario, planes e integraciones; llamada 2 = infraestructura, entidades, testing y setup; llamada 3 (solo si `ETAPA = producción/mantenimiento`) = bugs conocidos. Cada una es de opciones «Sí» / «No» (la recomendada primero según lo visto en el repo; sin señal, «No»), con el header indicado entre paréntesis. Lo visto en el repo que respalda las recomendadas va en una línea, en la descripción de la opción recomendada o en el enunciado, sin mensaje previo:

- (`Multi`) "¿Van a trabajar varias personas en paralelo en este proyecto, cada una con su agente?" (también se pregunta con `ALCANCE = b`)
  → Sí: **modo multi-operador**, ver la sección homónima más abajo. No: estructura plana, sin cambios.

- (`Bugs`) **Solo si `ETAPA = producción/mantenimiento`:** "¿Hay bugs conocidos o zonas frágiles del código que un agente debería evitar tocar sin cuidado?"
  → Sí: copiar `template/agents/known-issues.md` → `docs/agents/known-issues.md`

- (`Glosario`) "¿El proyecto maneja términos de negocio específicos que un agente externo no entendería a simple vista?"
  → Sí: copiar `template/project/glossary.md` → `docs/project/glossary.md`

- (`Planes`) "¿El proyecto tiene componente de costos, límites de uso o pagos?"
  → Sí: copiar toda la carpeta `template/plans/` → `docs/plans/` (`README.md`, `tiers.md`, `costs.md`, `limits.md`, `payments.md`)

- (`Integraciones`) "¿El proyecto integra servicios externos (APIs de terceros, IA, pasarelas de pago, etc.)?"
  → Sí: pasa a la **Ronda 4**. No: omitir carpeta `external/`.

- (`Infra`) "¿Hay infraestructura/deploy relevante que documentar?"
  → Sí: copiar `template/project/infrastructure.md` → `docs/project/infrastructure.md`

- (`Entidades`) "¿El proyecto tiene un modelo de datos o esquema de base de datos que valga la pena documentar aparte?"
  → Sí: copiar `template/project/entities.md` → `docs/project/entities.md`

- (`Testing`) "¿Hay una estrategia de testing establecida (o se quiere establecer)?"
  → Sí: copiar `template/project/testing.md` → `docs/project/testing.md`

- (`Setup`) "¿El setup local requiere pasos no triviales (variables de entorno, seeds, servicios externos corriendo)?"
  → Sí: copiar `template/project/setup.md` → `docs/project/setup.md`

---

## Ronda 4 — Seguimiento de integraciones externas (condicional)

Solo si en la Ronda 3 la respuesta fue "sí" a integraciones externas.

**Preguntar** (abierta, header `Servicios`; los servicios detectados y dónde van en una línea del enunciado, sin mensaje previo): "¿Cuántas y cuáles son?" Opciones: los servicios detectados en dependencias o variables de entorno como candidatos (recomendado primero, máximo 3) o, si no hay, «Lo escribo yo» y «No aplica / omitir»; la lista real llega por «Otro».

1. Copiar también `template/external/_example-service.md` → `docs/external/_example-service.md`, **sin renombrar ni modificar.** Queda ahí como plantilla disponible para que, más adelante, otra IA (o el operador) pueda documentar una nueva integración sin depender de esta skill.
2. Por cada servicio declarado ahora:
   - Duplicar `template/external/_example-service.md` → `docs/external/<nombre-servicio>.md`
   - Renombrar el título/contenido de la copia para reflejar el servicio real.

---

## Modo multi-operador (solo si en la Ronda 3 respondió que sí)

Las reglas del modo están en [`multi-operator.md`](./multi-operator.md) (abrirlo ahora, no antes). Cambia **dónde** se copian algunos archivos y suma otros; el resto del flujo no cambia:

1. **Operador actual:** leer `git config user.email` (si no está, preguntarlo) y preguntar con qué nombre corto registrarlo (minúsculas, sin espacios). Son preguntas abiertas e independientes: una sola llamada de `AskUserQuestion` (headers `Correo` y `Nombre`), con como candidatos el correo de git y el usuario de git en minúsculas, o «Lo escribo yo» y «No aplica / omitir» si no hay. Quien genera la documentación toma tareas, así que tiene carpeta.
2. **Dónde va cada archivo:**
   - `template/agents/rules.md`, `roadmap.md` y `known-issues.md` (según las condiciones de siempre) → `docs/agents/`, compartidos.
   - `template/agents/handoff.md`, `backlog.md` e `history.md` → `docs/agents/<operador>/`. Los enlaces a archivos compartidos pasan a `../` (ej. el de `rules.md`). Al revés, un archivo compartido (`roadmap.md`, los temas de `decisions/`) que enlaza a `backlog.md`, `handoff.md` o `history.md` no puede apuntar a una ruta fija: se reescribe como mención «el `backlog.md` de cada operador (`docs/agents/<operador>/`)», sin enlace.
   - `template/multi/operators.md` → `docs/agents/operators.md`, con la línea del operador actual (`- <carpeta>: <correo>`).
   - `template/multi/team-backlog.md` → `docs/agents/team-backlog.md`, vacío.
   - `template/multi/preferences.md` → `docs/agents/<operador>/preferences.md`, solo si el operador quiere definir sus preferencias; es opcional.
   - `template/multi/rules.md` no es un archivo: su bloque "Trabajo en paralelo" se agrega a `docs/agents/rules.md`, justo antes de "## Enlaces".
   - `docs/project/`, `docs/external/` y `docs/plans/` no cambian.
3. **`agents/history.md` reconstruido desde git** (Ronda 2): va a la carpeta de quien genera la documentación.
4. **`AGENTS.md`:** se usa `template/multi/AGENTS.md` en lugar de `template/AGENTS.md`; todo lo demás del paso (ruta, marcadores, archivo existente) es igual. `CLAUDE.md` no cambia.
5. **`docs/README.md`:** el árbol de `agents/` muestra `operators.md`, `team-backlog.md` y las carpetas de operador, y la definición de "operador" va en plural (ver la guía de `template/README.md`).
6. Los demás operadores se registran solos: la primera vez que su agente no encuentre su correo en `operators.md`, se lo pregunta (lo dice el propio `AGENTS.md` multi): el correo con `AskUserQuestion` y el nombre corto y el rol, que necesitan ver `operators.md`, en texto (regla 5).

---

## Ronda final — Generar README + puntero en la raíz (siempre, en cualquier rama que haya copiado algo)

1. **Generar `docs/README.md`** (no copiar `template/README.md` literal): usando ese archivo solo como guía, armar el mapa mínimo (~1,5 KB como máximo) con la descripción del proyecto, la definición de "operador" y el árbol de `docs/` con solo los archivos que existen tras esta ejecución (si no se copió `glossary.md`, no aparece; si se crearon 3 `external/*.md`, los 3 quedan listados). Este paso se omite en el set mínimo (no hay README en ese set); en ese caso, el paso 3 tampoco enlaza a `docs/README.md`.
   - **Descripción del proyecto:** si `docs/README.md` no existe todavía, o existe pero no la tiene, preguntar (abierta, header `Descripción`; lo visto en el `README.md` o `package.json` de donde sale la frase propuesta va en una línea del enunciado, sin mensaje previo): *"¿Puedes describir en 1-2 frases qué es este proyecto (qué hace, para quién)?"*, con como candidato una frase propuesta a partir del `README.md` o `package.json` si existen, o «Lo escribo yo» y «No aplica / omitir»; la descripción real llega por «Otro». Escribirla justo debajo del título. Si ya existe, preservarla tal cual al regenerar el resto — no se vuelve a preguntar.
2. Determinar si se usó `docs/` o `agent-context/` (según «Carpeta destino», más arriba).
3. **`AGENTS.md` (fuente de verdad — se asegura siempre, en cualquier set, incluso el mínimo):**
   - No existe → crear a partir de `template/AGENTS.md` (o `template/multi/AGENTS.md` en modo multi), ajustando la ruta `docs/`/`agent-context/` y quitando las líneas de los archivos que no se generaron (en el set mínimo: `docs/README.md`, `backlog.md` e `history.md`).
   - Existe con otro contenido del operador → no se sobrescribe: se agrega la sección delimitada `<!-- agent-context-skill:start -->` ... `<!-- agent-context-skill:end -->` de `template/AGENTS.md` (o `template/multi/AGENTS.md` en modo multi) al final, solo si el marcador (o el anterior `agent-docs-skill:start`) no está ya presente.
4. **`CLAUDE.md` (redirige a `AGENTS.md`, nunca duplica su contenido — se asegura siempre, en cualquier set):**
   - No existe → crear a partir de `template/CLAUDE.md`, literal.
   - Existe con otro contenido del operador → agregar la sección delimitada de `template/CLAUDE.md` al final, solo si el marcador (o el anterior `agent-docs-skill:start`) no está ya presente.
5. Si `ALCANCE` fue `a` o `c` (set mínimo) → preguntar opt-in de cierre (header `Completa`, opciones «No (Recomendado)» y «Sí»):

   **"¿Quieres igual la documentación completa porque vas a seguir trabajando este proyecto?"**
   - **Sí** → volver a la Ronda 2 y correr el flujo completo.
   - **No** → fin.

**Cierre:** al terminar de verdad el flujo, el mensaje de cierre lleva siempre la recomendación de [`suite-recommendation.md`](./suite-recommendation.md). Si el operador responde «Sí» en el paso 5, el flujo vuelve a la Ronda 2 y la recomendación no se da todavía: va solo al terminar el flujo completo.

---

## Resumen — sets de archivos

| Set | Se dispara con | Archivos incluidos |
|---|---|---|
| **Mínimo** | a) Tarea puntual / c) Testear algo puntual | `agents/rules.md`, `agents/handoff.md`, `AGENTS.md`/`CLAUDE.md` (raíz) |
| **Intermedio** | b) Agregar una feature a un proyecto existente | Todo el mínimo + `agents/backlog.md`, `agents/history.md`, `project/architecture.md`, `project/decisions/README.md`, `project/decisions/stack.md`, `README.md` (generado) |
| **Completo** | d) Desarrollo prolongado / proyecto nuevo | Todo el intermedio + los condicionales de Ronda 2-4 (`roadmap`, temas de `decisions/`, `known-issues`, `glossary`, `entities`, `infrastructure`, `testing`, `setup`, `external/*`, `plans/*`) |

## Resumen — condición de disparo por archivo

| Archivo | Se copia cuando |
|---|---|
| `README.md` | Se genera (no se copia) en set intermedio y completo, listando solo los archivos que existan (no en mínimo) |
| `AGENTS.md` (raíz) | Siempre — fuente de verdad, desde `template/AGENTS.md` |
| `CLAUDE.md` (raíz) | Siempre — redirige a `AGENTS.md`, desde `template/CLAUDE.md` |
| `agents/rules.md` | Siempre |
| `agents/handoff.md` | Siempre |
| `agents/backlog.md` | Set intermedio y completo |
| `agents/history.md` | Set intermedio y completo |
| `agents/roadmap.md` | Set completo y `ETAPA` ≠ `idea/setup` (en una migración, solo si la documentación vieja tenía uno) |
| `agents/known-issues.md` | Set completo, `ETAPA` = `producción/mantenimiento` y hay bugs/zonas frágiles conocidas |
| `project/architecture.md` | Set intermedio y completo |
| `project/decisions/README.md` y `project/decisions/stack.md` | Set intermedio y completo, desde la etapa `idea/setup` |
| `project/decisions/<tema>.md` | Hay una decisión firme que registrar (no se copian vacíos) |
| `project/glossary.md` | Hay términos de negocio propios |
| `project/entities.md` | Hay modelo de datos/esquema relevante |
| `project/infrastructure.md` | Hay infraestructura/deploy relevante |
| `project/testing.md` | Hay estrategia de testing (o se quiere establecer) |
| `project/setup.md` | Setup local no trivial |
| `agents/operators.md`, `agents/team-backlog.md` (de `template/multi/`) | Solo en modo multi-operador |
| `<operador>/preferences.md` (de `template/multi/`) | Solo en modo multi-operador y si el operador quiere definirlas |
| `agents/handoff.md`, `backlog.md`, `history.md` | En modo multi van a `agents/<operador>/` (sección "Modo multi-operador") |
| `external/_example-service.md` (plantilla) | Se copia sin renombrar junto con las integraciones declaradas, para que quede disponible si se agregan más adelante |
| `external/<servicio>.md` | Por cada integración externa declarada |
| `plans/*` | Hay costos, límites de uso o pagos |
