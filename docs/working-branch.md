# Rama de trabajo

Instrucción para el agente: los flujos que escriben en el repo del operador ([`questions-flow.md`](./questions-flow.md), [`migration-flow.md`](./migration-flow.md) y [`update-flow.md`](./update-flow.md)) trabajan en una rama nueva y, al terminar, le ofrecen al operador hacer el merge para volver a la rama en la que estaba. Una sola rama por ejecución: si un flujo continúa en otro (migrar sigue con `questions-flow.md`), se reutiliza.

## Al empezar

Antes de escribir el primer archivo (en migración, después de la ronda de confirmación):

1. Anotar la rama de partida con `git branch --show-current`. Si sale vacío (HEAD desacoplado), parar y pedir que se pase a una rama.
2. Crear la rama nueva desde ella con `git switch -c`: `agent-context-generate`, `agent-context-migrate` o `agent-context-update-<versión destino>` (si existe, sufijo numérico).
3. No se improvisa: si la rama no se puede crear, no se sigue sobre la rama de partida. El flujo se detiene y se le dice al operador por qué.
4. Sin repo git: [`update-flow.md`](./update-flow.md) para. Generar y migrar avisan de que no hay rama ni cómo revertir y siguen solo con confirmación explícita (`AskUserQuestion`), sin rama ni merge.

## Al terminar

1. **Commit.** Con confirmación, un commit en la rama nueva solo con los archivos que tocó el flujo: mostrar la lista y el mensaje propuesto, y preguntar en texto como mensaje final del turno (regla 5 de [`asking-questions.md`](./asking-questions.md)). Los mensajes van en inglés: `docs: generate the agent-context documentation`, `docs: migrate the documentation to agent-context` o `docs: update the agent-context documentation from skill X to Y`. Informar el nombre de la rama, el resumen del flujo y cómo revisar (`git diff <rama de partida>..<rama nueva>`).
2. **Merge a la rama de partida.** Con el commit hecho, en un mensaje aparte que cierra el turno (regla 5), con el hash del commit, los archivos y `git diff <rama de partida>..<rama nueva>` como contexto, preguntar en texto: «¿Hago el merge de `<rama nueva>` en `<rama de partida>`?», con «Hacer el merge» / «Dejar la rama para revisarla».
   - Con «Hacer el merge»: `git switch <rama de partida>` y `git merge --no-ff -m "<el mismo mensaje del commit>" <rama nueva>` (con `-m`, para que no se abra un editor). Si hay conflictos, parar, mostrarlos y preguntar si se resuelven juntos o se corta con `git merge --abort`; no se resuelven sin el operador.
   - Nunca `git push`.
   - Con «Dejar la rama», informar cómo hacerlo después.
   - Si el operador descartó el commit, los cambios quedan sin commitear en la rama nueva: decirle en qué rama quedó y no preguntar el merge.
3. **Oferta de la suite**, en el mensaje que informa el resultado, después del merge (o de que lo rechace, o de los conflictos): ver [`suite-recommendation.md`](./suite-recommendation.md). Nunca va en una pregunta.
