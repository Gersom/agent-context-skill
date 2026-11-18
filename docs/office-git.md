# Git del perfil no técnico

La persona no ve git: lo usa el agente. Solo se versionan la documentación y los archivos de la skill.

## Antes de instalar

1. Rechaza el home (`$HOME`), la raíz de una unidad (`C:/`) y `C:/Windows`, `C:/Program Files` o `C:/ProgramData`.
2. `git rev-parse --show-prefix`: error = sin repo. Con texto = dentro de otro proyecto: avisa «ya hay un proyecto en `<git rev-parse --show-toplevel>`; crea otra carpeta y empieza desde ahí» y para. Vacío = raíz de su repo, se reutiliza (aunque no tenga commits).
3. Una sola confirmación: «Voy a instalar todo lo necesario para usar la skill en esta carpeta (`<ruta>`): documentación, instrucciones para el agente y seguimiento de cambios. ¿Me confirmas?»

## Instalar

- Sin repo: `git init`.
- Si `git config user.name` o `user.email` salen vacíos: `git config --local user.name Agent` y `--local user.email agent@localhost`; nunca `--global`.
- `.gitignore`: `*`, `!*/`, `!.gitignore`, `!AGENTS.md`, `!CLAUDE.md`, `!docs/**/*.md`. Si existe, agrega solo las que falten. Prueba: `git check-ignore -q -- ventas.xlsx` da 0 y con `AGENTS.md`, 1.
- Primer commit: `git add -- docs AGENTS.md .gitignore`, más `git add -- CLAUDE.md` si existe, y `git commit -m "chore: install agent context"`.

## Commits

Tras cada cambio de estado, el mismo `git add` (nunca `-A`) y `git commit -m "docs(T-N): start|pause|resume|close task"`, en inglés. Sin cambios, no commitees. Entrecomilla rutas con espacios.
