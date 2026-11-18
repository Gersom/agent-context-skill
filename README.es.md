[English](./README.md) | Español

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

## Install in other agents

The skill follows the open [Agent Skills](https://agentskills.io) standard, so it is not limited to Claude Code. To install it in other agents (Codex, Cursor, Gemini CLI, GitHub Copilot and more), run this in your project:

```sh
npx skills add Gersom/agent-context-skill
```

## Usar

Pídeselo al agente al empezar a trabajar en un repositorio:

- **"Usa la skill agent-context-skill"**: si el repo ya tiene documentación de la skill, sigue el flujo existente; si no, evalúa si hay documentación de otro sistema para migrar o dispara el árbol de preguntas para generarla.
- **"Usa la skill agent-context-skill y migra mi proyecto"**: fuerza el chequeo de migración (ver [`docs/migration-flow.md`](./docs/migration-flow.md)).

## Para trabajo de oficina (perfil no técnico)

Si usas la carpeta para tu trabajo del día a día (documentos, hojas de cálculo, imágenes) y no para programar, la skill lo pregunta al empezar («¿Para qué vas a usar esta carpeta?») e instala un perfil propio:

- **Sin jerga y sin planes:** el agente hace lo que le pides y te habla en lenguaje llano; no hay `project/`, ni planes, ni modos de ejecución.
- **Tareas que se pausan y se retoman:** registra una tarea solo cuando el trabajo es de varios pasos o cuando cambias de tema. Frases como «pausa esto», «sigamos con lo del Excel» o «ya terminé» pausan, retoman y cierran tareas. Con varias empresas o proyectos en una carpeta, cada tarea lleva una etiqueta.
- **Copia de seguridad:** antes de modificar un archivo tuyo guarda una copia en `backups/`, y la borra al cerrar la tarea.
- **Git, sin que lo veas:** lo prepara y lo usa el agente tras una única confirmación, y solo versiona la documentación, no tus archivos de trabajo.
- **Requiere** el comando `acsuite` de [agent-context-suite](https://www.npmjs.com/package/agent-context-suite) (ver abajo): `acsuite board` muestra tus tareas.

El detalle está en [`docs/office-profile.md`](./docs/office-profile.md) y [`docs/office-git.md`](./docs/office-git.md).

## Herramientas complementarias (opcional)

La skill funciona sola. Quien además quiera ver y editar las tareas desde la terminal y comprobar que la documentación esté en orden puede usar **agent-context-suite** (https://www.npmjs.com/package/agent-context-suite), publicada por el mismo autor como paquete de npm con el comando `acsuite`:

- `acsuite board`: tablero de tareas en vivo.
- `acsuite task`: consultar y editar las tareas sin tocar a mano `handoff.md`, `backlog.md` ni `history.md`.
- `acsuite check`: verifica la documentación.

Se instala con `npm install -g agent-context-suite` (Node 20 o superior) y su README explica el uso.

## Qué hay en el repo

```
SKILL.md        # Punto de entrada: cuándo se dispara y qué hace
docs/           # Flujos (questions-flow, migration-flow, multi-operator, update-flow, working-branch, version-check, asking-questions, suite-recommendation, office-profile, office-git), template-architecture.md y changelog/
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
