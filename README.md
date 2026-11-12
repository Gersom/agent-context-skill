English | [Español](./README.es.md)

# agent-context-skill

Claude Code skill that generates or updates a project's context documentation (rules, hot state, backlog, history, architecture) so that any AI agent knows where the project stands without depending on the memory of a conversation.

## Install as a Claude Code plugin

From a Claude Code session:

```
/plugin marketplace add Gersom/agent-context-skill
/plugin install agent-context-skill@agent-context-skill
```

Or from the terminal:

```sh
claude plugin marketplace add Gersom/agent-context-skill
claude plugin install agent-context-skill@agent-context-skill
```

To pin a version, add the marketplace with a tag: `Gersom/agent-context-skill@v1.9.0`. To update: `claude plugin update agent-context-skill` (restart the session to apply it). If you installed it earlier as `agent-context-kit@agent-context-skill`, reinstall it under the new name: the skill was renamed to match its repo.

## Install in other agents

The skill follows the open [Agent Skills](https://agentskills.io) standard, so it is not limited to Claude Code. To install it in other agents (Codex, Cursor, Gemini CLI, GitHub Copilot and more), run this in your project:

```sh
npx skills add Gersom/agent-context-skill
```

## Use

Ask the agent when you start working in a repository:

- **"Use the agent-context-skill skill"**: if the repo already has the skill's documentation, it follows the existing flow; if not, it checks whether there is documentation from another system to migrate or triggers the question tree to generate it.
- **"Use the agent-context-skill skill and migrate my project"**: forces the migration check (see [`docs/migration-flow.md`](./docs/migration-flow.md)).

## Complementary tools (optional)

The skill works on its own. If you also want to view and edit tasks from the terminal and check that the documentation is in order, you can use **agent-context-suite** (https://www.npmjs.com/package/agent-context-suite), published by the same author as an npm package with the `acsuite` command:

- `acsuite board`: live task board.
- `acsuite task`: query and edit tasks without hand-editing `handoff.md`, `backlog.md` or `history.md`.
- `acsuite check`: verifies the documentation.

Install it with `npm install -g agent-context-suite` (Node 20 or higher); its README explains how to use it.

## What is in the repo

```
SKILL.md        # Entry point: when it triggers and what it does
docs/           # Flows (questions-flow, migration-flow, multi-operator, update-flow, working-branch, version-check, asking-questions, suite-recommendation), template-architecture.md and changelog/
template/       # Catalog of templates the skill copies into the target repo
.claude-plugin/ # plugin.json and marketplace.json
LICENSE         # MIT license
```

What each template is: [`docs/template-architecture.md`](./docs/template-architecture.md).

## Versioning

SemVer, with `vX.Y.Z` tags and the version in `.claude-plugin/plugin.json`. As long as `plugin.json` sets `version`, operators get an update only when it is bumped. The version lives in `.claude-plugin/plugin.json`, in `SKILL.md` ("Versión de esta skill") and in the marker of `template/agents/rules.md`, and they must match; the `vX.Y.Z` tag is created on release. Each minor or major version has its file in `docs/changelog/` (see its [README](./docs/changelog/README.md)).

- **patch**: fixes or wording adjustments in existing templates.
- **minor**: new content that breaks nothing (a new template, a new branch of the question tree).
- **major**: changes that break something a target repo might already use (moving or renaming `template/` files referenced from `questions-flow.md`, changing the structure generated in `docs/agents` or `docs/project`).

## License

[MIT](./LICENSE). You can use the skill, copy its templates into your projects and redistribute it, keeping the copyright notice.

## Support the project

If the skill is useful to you and you want to support its development, you can donate through PayPal: [paypal.me/gersomalaja](https://paypal.me/gersomalaja).
