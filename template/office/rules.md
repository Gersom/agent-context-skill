<!-- agent-context-skill:version 2.5.0 — versión de la skill con la que se generaron las Reglas por defecto de este archivo; ignorar al leer, no es contenido. Lo usa la skill para detectar versiones más nuevas (ver docs/version-check.md de la skill). -->
# Reglas del proyecto

<!-- agent-context-suite:start -->
### Herramientas de la suite

Este proyecto usa [agent-context-suite](https://github.com/Gersom/agent-context-suite). No edites a mano `handoff.md`, `backlog.md` ni `history.md`: usa `acsuite task` (el detalle: `acsuite task --help`). Para verificar la documentación, `acsuite check`; para ver el tablero, `acsuite board`.
<!-- agent-context-suite:end -->

Este proyecto lo usa una persona que no programa. Estas reglas valen para todo lo que hagas aquí.

1. **Habla en lenguaje llano.** Di tareas, archivos y temas; nunca commits, ramas, comandos ni pasos técnicos. Usa las palabras de la persona (empresas, proyectos, clientes, lo que ella diga).

2. **Haz, sin plan ni modo.** Ejecuta lo que pide. Una pregunta, una explicación o una sugerencia no autoriza a cambiar nada: solo se edita cuando pide hacerlo. Ante una duda real, una sola pregunta con opciones numeradas, y espera.

3. **Cuándo registrar una tarea.** Regístrala (`acsuite task add` y `start`, sin `--plan` y sin `step`: el avance se registra solo al pausar) si lo que pide toca un archivo y no es un cambio de un solo paso (un paso es una sola operación sobre el archivo: ordenar y quitar duplicados son dos), o si la persona cambia de tema o deja algo para después. Las consultas y los ajustes de un paso se hacen directo, sin registrar. Solo hay una tarea en curso a la vez.

4. **Frases a comandos** (siempre con `--apply`; el detalle: `acsuite task <comando> --help`). La persona nunca los ve:
   - «pausa esto», «ahora vamos con otra cosa» → `pause --reason "…" --waiting-for "…" --missing "…" --next "…"` (`--missing`: qué falta; `--next`: el próximo paso).
   - «sigamos con lo del Excel» → `resume <N>`; antes, pausa la que esté en curso. Si hay varias pausadas, pregunta cuál.
   - «ya terminé», «listo, está bien así» → `close --done --summary "…" --commits auto` (sin `--commits` si no hay git). Solo cierra cuando lo dice con claridad. Si nombra una pausada («ya terminé con lo de Beta»), `close <N>` de esa, sin tocar la que está en curso; si no queda claro cuál, pregunta con opciones numeradas.
   - «no la hagas» o «descártalo todo» → `close --discarded --reason "…"`.

5. **Varios contextos.** Si la persona trabaja con varias empresas, proyectos o clientes, ponle a cada tarea una etiqueta (`--labels`) con el nombre que ella use: solo letras y números, sin tildes. Cambiar de contexto pausa la tarea en curso. Si el contexto no está claro, pregunta una vez con opciones numeradas; la etiqueta queda en la tarea.

6. **Copia de seguridad.** Antes de modificar por primera vez un archivo de la persona en una tarea, copia el original a `backups/` en la raíz como `<nombre>_backup_T<N>_<AAAA-MM-DD>_<HHMM>.<ext>` (hora local; `date +%Y-%m-%d_%H%M`), una por archivo y por tarea. Un ajuste directo (de un solo paso) no tiene copia: si piden deshacerlo, díselo en llano y reescribe el valor anterior. Al editar un archivo de la persona conserva su formato (saltos de línea, codificación, orden y comillas) y cambia solo lo pedido, sin reescribirlo entero. Si dice que no le gustó, restaura el archivo (copia la copia entera sobre él; si solo quiere deshacer una parte, pregunta cuál) y, si la tarea sigue abierta, actualízala con `task edit --missing --next` (al descartarla no hace falta). Al cerrar, borra solo los archivos de `backups/` que coinciden con `*_backup_T<N>_*` (con los guiones bajos), y solo después de que el cierre salió bien; si la descarta o pide dejarlo como estaba, restaura antes de borrar. Nunca borres otra cosa de `backups/`.

7. **Git, solo si está instalado** (`git --version`). Si no lo está, sigue sin él y sin avisar. Si lo está, tras cada cambio en `docs/` por una tarea (`add|update|start|pause|resume|close`; un `edit` es `update`) haz `git add --` de `docs`, `AGENTS.md`, `CLAUDE.md` y `.gitignore` (solo las rutas que existan; nunca `-A`) y `git commit -m "docs(T-N): <add|update|start|pause|resume|close> task"`, en inglés. Sin cambios, no commitees. Los archivos de trabajo (Excel, imágenes, `backups/`) no se versionan: el `.gitignore` los deja fuera.

8. **Al cerrar, resume en una o dos frases** qué quedó hecho, sin hashes ni términos técnicos. Si queda algo pendiente, dilo en una frase. Si se descartó y restauraste el archivo, dilo: «lo dejé como estaba».

9. **Idioma de la documentación:** lo que redactes en `docs/` va en el idioma registrado abajo; no se vuelve a preguntar. Siempre en inglés: nombres de archivo y carpeta, y los mensajes de commit.

   **Idioma de la documentación:** [Placeholder — se completa la primera vez que se genera esta documentación]

10. **Los encabezados de `handoff.md`, `backlog.md` e `history.md`** citan reglas del modelo general (plan, evidencia por paso, reglas de cierre): aquí no aplican; vale lo de este archivo.

11. **El archivo de la persona es la verdad.** Si estas reglas contradicen lo que ella te pide para un caso concreto, gana lo que pide.
