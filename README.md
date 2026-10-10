# agent-context-skill

Skill de Claude Code que genera o actualiza la documentación de contexto de un proyecto (reglas, estado en caliente, backlog, historial, arquitectura) para que cualquier agente de IA sepa en qué momento está el proyecto sin depender de la memoria de una conversación.

La skill se llama `agent-context-kit` (el nombre de su `SKILL.md`); este repo se llama `agent-context-skill`.

## Instalar como plugin de Claude Code

Desde una sesión de Claude Code:

```
/plugin marketplace add Gersom/agent-context-skill
/plugin install agent-context-kit@agent-context-skill
```

O desde la terminal:

```sh
claude plugin marketplace add Gersom/agent-context-skill
claude plugin install agent-context-kit@agent-context-skill
```

Para fijar una versión, agrega el marketplace con un tag: `Gersom/agent-context-skill@v1.8.0`. Para actualizar: `claude plugin update agent-context-kit` (hay que reiniciar la sesión para aplicarlo).

## Usar

Pídeselo al agente al empezar a trabajar en un repositorio:

- **"Usa la skill agent-context-kit"**: si el repo ya tiene documentación de la skill, sigue el flujo existente; si no, evalúa si hay documentación de otro sistema para migrar o dispara el árbol de preguntas para generarla.
- **"Usa la skill agent-context-kit y migra mi proyecto"**: fuerza el chequeo de migración (ver [`docs/migration-flow.md`](./docs/migration-flow.md)).

## Qué hay en el repo

```
SKILL.md        # Punto de entrada: cuándo se dispara y qué hace
docs/           # Flujos (questions-flow, migration-flow, multi-operator) y template-architecture.md
template/       # Catálogo de plantillas que la skill copia al repo destino
.claude-plugin/ # plugin.json y marketplace.json
```

Qué es cada plantilla: [`docs/template-architecture.md`](./docs/template-architecture.md).

## Versionado

SemVer, con tags `vX.Y.Z` y la versión en `.claude-plugin/plugin.json`. Mientras `plugin.json` fije `version`, los usuarios reciben una actualización solo al subirla.

- **patch**: fixes o ajustes de redacción en plantillas existentes.
- **minor**: contenido nuevo que no rompe nada (una plantilla nueva, una rama nueva del árbol de preguntas).
- **major**: cambios que rompen algo que un repo destino ya pudiera usar (mover o renombrar archivos de `template/` referenciados desde `questions-flow.md`, cambiar la estructura generada en `docs/agents` o `docs/project`).
