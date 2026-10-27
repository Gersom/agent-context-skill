# Rama de trabajo

Instrucción para el agente: los flujos que escriben en el repo del operador ([`questions-flow.md`](./questions-flow.md), [`migration-flow.md`](./migration-flow.md) y [`update-flow.md`](./update-flow.md)) trabajan en una rama nueva y, al terminar, le ofrecen al operador hacer el merge para volver a la rama en la que estaba. Quedan fuera los ajustes sueltos fuera de esos flujos (por ejemplo, renombrar marcadores heredados sin actualizar, o pasar de plano a multi-operador), que se hacen en la rama actual y se dejan sin commitear para que el operador los revise.

**Una sola rama por ejecución.** Si un flujo continúa en otro (migrar sigue con `questions-flow.md`, paso 4 de la ejecución), la rama ya existe: no se crea otra, se conserva la rama de partida anotada al principio y el commit, el merge y el cierre los da una sola vez el flujo que empezó (migrar).

## Al empezar

Antes de escribir el primer archivo (en migración, después de la ronda de confirmación):

1. **Sin git.** [`update-flow.md`](./update-flow.md) para. Generar y migrar avisan de que no hay rama ni cómo revertir y siguen solo con confirmación explícita (`AskUserQuestion`; en migrar es la misma de la «Precondición: git limpio», no se pregunta dos veces), sin rama ni merge: al terminar no hay commit ni pregunta del merge, solo el resumen y la oferta de la suite.
2. **Sin commits todavía** (`git rev-parse --verify HEAD` falla). No hay rama de partida a la que volver: se trabaja en la rama actual, se hace el commit con confirmación y no se pregunta el merge.
3. **HEAD desacoplado** (`git branch --show-current` sale vacío). Parar y pedir que se pase a una rama.
4. **Cambios previos del operador.** Mirar `git status --porcelain` antes de crear la rama. Si hay cambios sin commitear en rutas que el flujo va a tocar (`docs/` o `agent-context/`, `AGENTS.md`, `CLAUDE.md` y, en migración, las carpetas de origen), parar y pedir que se commiteen o guarden antes, en la rama de partida. Los cambios en otras rutas se llevan a la rama nueva y no entran en el commit del flujo.
5. **Crear la rama** desde la de partida con `git switch -c`: `agent-context-generate`, `agent-context-migrate` o `agent-context-update-<versión destino>` (si existe, sufijo numérico). Anotar antes la rama de partida (`git branch --show-current`).
6. No se improvisa: si la rama no se puede crear, no se sigue sobre la rama de partida. El flujo se detiene y se le dice al operador por qué.

## Al terminar

Si el flujo no escribió nada (por ejemplo, el operador omitió todos los cambios de una actualización), no hay nada que commitear: se informa, se vuelve a la rama de partida, no se pregunta el merge, la rama nueva (vacía, sin nada que fusionar) se borra con `git branch -d <rama nueva>` y se da la oferta de la suite.

1. **Commit.** Con confirmación, un commit en la rama nueva solo con los archivos que tocó el flujo (`git add -- <rutas>`, nunca `git add -A`): mostrar la lista y el mensaje propuesto, y preguntar en texto como mensaje final del turno (regla 5 de [`asking-questions.md`](./asking-questions.md)). Los mensajes van en inglés: `docs: generate the agent-context documentation`, `docs: migrate the documentation to agent-context` o `docs: update the agent-context documentation from skill X to Y`; si el proyecto define su propia convención de commits, prevalece. Informar el nombre de la rama, el resumen del flujo y cómo revisar (`git diff <rama de partida>..<rama nueva>`).
2. **Merge a la rama de partida.** Con el commit hecho, en un mensaje aparte que cierra el turno (regla 5), con el hash del commit, los archivos y `git diff <rama de partida>..<rama nueva>` como contexto, preguntar en texto: «¿Hago el merge de `<rama nueva>` en `<rama de partida>`?», con «Hacer el merge» / «Dejar la rama para revisarla».
   - Con «Hacer el merge»: `git switch <rama de partida>` y `git merge --no-ff -m "<el mismo mensaje del commit>" <rama nueva>` (con `-m`, para que no se abra un editor). Si hay conflictos, parar, mostrarlos y preguntar si se resuelven juntos o se corta con `git merge --abort`; no se resuelven sin el operador.
   - Con el merge hecho (sin conflictos), borrar la rama nueva con `git branch -d <rama nueva>` (la `-d` minúscula: git se niega si no está fusionada, y no se fuerza con `-D`). Si el borrado falla, informarlo y dejarla. En el mensaje de resultado, decir si la rama se borró o se dejó, y por qué.
   - Si hubo conflictos, la rama no se borra aunque el operador complete el merge: queda para que la revise, y se le dice.
   - Nunca `git push`, ni se borran ramas remotas.
   - Con «Dejar la rama», informar cómo hacer el merge después y que, hecho, se borra con `git branch -d <rama nueva>`.
   - Si el operador descartó el commit, los cambios quedan sin commitear en la rama nueva: decirle en qué rama quedó y no preguntar el merge.
3. **Oferta de la suite**, en el mensaje que informa el resultado, después del merge (o de que lo rechace, de los conflictos o de que el operador descarte el commit): ver [`suite-recommendation.md`](./suite-recommendation.md). Nunca va en una pregunta.
