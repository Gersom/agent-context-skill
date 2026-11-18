# Perfil no técnico

Para quien usa la carpeta con documentos, hojas de cálculo o imágenes. Sin rondas de proyecto, `project/`, `docs/README.md`, multi-operador ni rama de trabajo (la reemplaza [`office-git.md`](./office-git.md)). Habla en lenguaje llano.

1. `IDIOMA`, como siempre. «Carpeta destino» rige: con `agent-context/`, úsala en lugar de `docs/` en lo que copies, el `.gitignore` y los `git add`.
2. El punto 1 de «Antes de instalar» de `office-git.md` aplica siempre. Si `git --version` funciona, aplica también el 2 y el 3; si no, sigue sin git y confirma con: «Voy a instalar todo lo necesario para usar la skill en esta carpeta (`<ruta>`): documentación e instrucciones para el agente. ¿Me confirmas?» Sin un sí, no se crea nada.
3. Crea desde `template/`, sin comentarios guía (salvo marcas de máquina; ver «Al copiar una plantilla» de `questions-flow.md`):
   - `agents/{handoff,backlog,history}.md` → `docs/agents/`. `backlog` e `history`: «Ninguna.» en lugar de los ejemplos. `handoff`: «Sin tarea en curso» y «Ninguna.», sin párrafos de ejemplo.
   - `office/rules.md` → `docs/agents/rules.md`, con `IDIOMA` registrado. No ofrezcas la recomendación de la suite (`suite-recommendation.md`): `rules.md` ya la lleva.
   - `office/AGENTS.md` → `AGENTS.md` y `template/CLAUDE.md` → `CLAUDE.md`, en la raíz; si ya existen con contenido propio, solo la sección delimitada.
   - Con git: `office/gitignore.txt` → `.gitignore` (si existe, agrega las líneas que falten).
4. Con git: `git init` si falta, identidad local y primer commit, como dice «Instalar» de `office-git.md`.
5. Si `acsuite --help` responde, `acsuite check <carpeta>`.
6. Cierre, sin rutas ni jerga: «Listo. Pídeme lo que necesites; si tienes que dejar algo para después, dime "pausa esto" y lo retomamos cuando quieras.»
