# agent-context-skill

Skill de Claude Code que genera o actualiza la documentación de contexto de un proyecto (reglas, estado en caliente, backlog, historial, arquitectura) para que cualquier agente de IA sepa en qué momento está el proyecto sin depender de la memoria de una conversación.

## Instalar como plugin de Claude Code

Desde una sesión de Claude Code:

```
/plugin marketplace add Gersom/agent-context-skill
/plugin install agent-context-skill@agent-context-skill
```

O desde la terminal:

```sh
claude plugin marketplace add Gersom/agent-context-skill
claude plugin install agent-context-skill@agent-context-skill
```

Para fijar una versión, agrega el marketplace con un tag: `Gersom/agent-context-skill@v1.9.0`. Para actualizar: `claude plugin update agent-context-skill` (hay que reiniciar la sesión para aplicarlo). Si la instalaste antes como `agent-context-kit@agent-context-skill`, reinstálala con el nombre nuevo: la skill pasó a llamarse igual que su repo.

## Usar

Pídeselo al agente al empezar a trabajar en un repositorio:

- **"Usa la skill agent-context-skill"**: si el repo ya tiene documentación de la skill, sigue el flujo existente; si no, evalúa si hay documentación de otro sistema para migrar o dispara el árbol de preguntas para generarla.
- **"Usa la skill agent-context-skill y migra mi proyecto"**: fuerza el chequeo de migración (ver [`docs/migration-flow.md`](./docs/migration-flow.md)).

## Herramientas complementarias (opcional)

La skill funciona sola. Quien además quiera ver y editar las tareas desde la terminal y comprobar que la documentación esté en orden puede usar **agent-context-suite** (https://github.com/Gersom/agent-context-suite), publicada por el mismo autor como paquete de npm con el comando `acsuite`:

- `acsuite board`: tablero de tareas en vivo.
- `acsuite task`: consultar y editar las tareas sin tocar a mano `handoff.md`, `backlog.md` ni `history.md`.
- `acsuite check`: verifica la documentación.

Se instala con `npm install -g agent-context-suite` (Node 20 o superior) y su README explica el uso.

## Qué hay en el repo

```
SKILL.md        # Punto de entrada: cuándo se dispara y qué hace
docs/           # Flujos (questions-flow, migration-flow, multi-operator, update-flow, working-branch, version-check, asking-questions, suite-recommendation), template-architecture.md y changelog/
template/       # Catálogo de plantillas que la skill copia al repo destino
.claude-plugin/ # plugin.json y marketplace.json
LICENSE         # Licencia MIT
```

Qué es cada plantilla: [`docs/template-architecture.md`](./docs/template-architecture.md).

## Versionado

SemVer, con tags `vX.Y.Z` y la versión en `.claude-plugin/plugin.json`. Mientras `plugin.json` fije `version`, los operadores reciben una actualización solo al subirla. La versión vive en `.claude-plugin/plugin.json`, en `SKILL.md` («Versión de esta skill») y en el marcador de `template/agents/rules.md`, y deben coincidir; el tag `vX.Y.Z` se crea al publicar. Cada versión minor o major lleva su archivo en `docs/changelog/` (ver su [README](./docs/changelog/README.md)).

- **patch**: fixes o ajustes de redacción en plantillas existentes.
- **minor**: contenido nuevo que no rompe nada (una plantilla nueva, una rama nueva del árbol de preguntas).
- **major**: cambios que rompen algo que un repo destino ya pudiera usar (mover o renombrar archivos de `template/` referenciados desde `questions-flow.md`, cambiar la estructura generada en `docs/agents` o `docs/project`).

## Licencia

[MIT](./LICENSE). Puedes usar la skill y copiar sus plantillas en tus proyectos, y redistribuirla, conservando el aviso de copyright.

## Apoyar el proyecto

Si la skill te sirve y quieres apoyar su desarrollo, puedes hacer una donación por PayPal: [paypal.me/gersomalaja](https://paypal.me/gersomalaja).
