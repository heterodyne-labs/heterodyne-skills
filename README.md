# aphelion-skills

The Claude Code plugin marketplace for [aphelion](https://github.com/aphelion-labs/aphelion). It holds the skills, and the evals that test them, for aphelion's spec-driven agent loop: an issue becomes an OpenSpec change proposal, the owner approves it, an agent implements it on the same branch, and the change is archived into the living spec inside the same pull request.

aphelion's ADR 0012 puts project-wide skills in this separate repository, published as a plugin marketplace with `.claude-plugin/marketplace.json` at its root.

## Contents

| Path | What it is |
|---|---|
| `.claude-plugin/marketplace.json` | The marketplace `aphelion-skills`, owned by aphelion-labs, listing one plugin |
| `plugins/aphelion-sdlc/` | The plugin: skills `issue-propose`, `issue-finish`, `file-bug` and `triage`. See its [README](plugins/aphelion-sdlc/README.md) |
| `plugins/aphelion-sdlc/evals/` | `claude plugin eval` cases for each skill. See [evals/README.md](plugins/aphelion-sdlc/evals/README.md) |
| `.github/workflows/evals.yml` | Validates the manifests on every pull request; runs the evals on manual dispatch, and on pull requests once the owner enables it |
| `LICENSE` | Apache License 2.0 (aphelion ADR 0003) |

## Install

In a Claude Code session (Claude Code docs, "Install and manage plugins"):

```text
/plugin marketplace add aphelion-labs/aphelion-skills
/plugin install aphelion-sdlc@aphelion-skills
```

From a shell:

```bash
claude plugin marketplace add aphelion-labs/aphelion-skills
claude plugin install aphelion-sdlc@aphelion-skills
```

aphelion enables the plugin for everyone who works in it through its `.claude/settings.json`, with `extraKnownMarketplaces` naming this repository and `enabledPlugins` set to `"aphelion-sdlc@aphelion-skills": true`. That setting turns the plugin on but does not download it: each collaborator runs `claude plugin install aphelion-sdlc@aphelion-skills --scope project` once, after accepting the workspace trust dialog for the aphelion folder.

## Develop

Validate the manifests before pushing (no model calls):

```bash
claude plugin validate . --strict
claude plugin validate plugins/aphelion-sdlc --strict
```

Try the plugin without installing it: `claude --plugin-dir plugins/aphelion-sdlc` from a aphelion checkout.

Run the evals as [evals/README.md](plugins/aphelion-sdlc/evals/README.md) describes. Every eval run is a real model call on your account.

Release: bump `version` in `plugins/aphelion-sdlc/.claude-plugin/plugin.json`. Users get a new copy only when that version changes (Claude Code docs, "Host and maintain a marketplace"). How releases are tagged is an open decision.

## CI

`.github/workflows/evals.yml` has two jobs:

- `validate` runs `claude plugin validate --strict` on the marketplace and the plugin for every pull request that touches them.
- `evals` runs `claude plugin eval` with `CLAUDE_CODE_OAUTH_TOKEN` from the repository's secrets. It draws on the owner's Claude subscription, so it runs only on manual dispatch until the owner sets the repository variable `EVALS_ENABLED` to `true`. Pass/fail threshold, runs per case and cost ceiling are open decisions (aphelion ADR 0012); the owner can pass those flags through the repository variable `EVALS_EXTRA_ARGS`.

## License

Apache License 2.0. See [LICENSE](LICENSE).
