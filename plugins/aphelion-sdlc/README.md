# aphelion-sdlc

A Claude Code plugin with the four skills that drive aphelion's spec-driven agent loop. aphelion ([github.com/aphelion-labs/aphelion](https://github.com/aphelion-labs/aphelion)) keeps its specs as OpenSpec markdown in the repository and its tickets as GitHub Issues (ADR 0004). One issue becomes one pull request (ADR 0010):

1. **triage** gives the owner a first look at a new issue: duplicates, specs and ADRs it touches, proposed labels, missing fields. The owner decides.
2. **issue-propose** turns an issue into an OpenSpec change folder and a draft pull request, then stops. The owner approves the proposal.
3. The implementation happens on the same branch.
4. **issue-finish** ticks the tasks, runs `make check`, archives the change so the living spec updates inside the same pull request, runs `scripts/check-specs.sh`, rewrites the pull request body and marks it ready for review.
5. **file-bug** files a defect an agent finds outside its ticket, without fixing it on the current branch.

The ADR numbers refer to aphelion's `docs/decisions/`.

## Skills

| Skill | Command | Input | Leaves behind |
|---|---|---|---|
| issue-propose | `/aphelion-sdlc:issue-propose 12` | issue number | `openspec/changes/<N>-<slug>/`, one `docs:` commit, a draft PR, `status:spec-review`; or a comment and `status:blocked` |
| issue-finish | `/aphelion-sdlc:issue-finish 12` | issue number | ticked tasks, the archived change and updated living spec in one commit, the PR body rewritten and marked ready, `status:in-review` |
| file-bug | `/aphelion-sdlc:file-bug` | what you observed | a bug issue labelled `type:fix`, `status:needs-triage`, `origin:agent`, at most three per run |
| triage | `/aphelion-sdlc:triage 31` | issue number | one structured comment proposing labels; no label change |

The bare `/issue-propose` and so on also work when no other command uses the name (Claude Code docs, skills). Claude can also pick a skill from its description, which is how file-bug fires in the middle of an implementation run.

Each `SKILL.md` has the sections when to use, inputs, steps, hard rules and done when. All four tell Claude to read aphelion's `CLAUDE.md` first and to stop and ask the owner where it disagrees with the skill.

## Install

From the marketplace, in a Claude Code session (Claude Code docs, "Install and manage plugins"):

```text
/plugin marketplace add aphelion-labs/aphelion-skills
/plugin install aphelion-sdlc@aphelion-skills
```

In a session, `/plugin install` opens the plugin's details so you can choose a scope. From a shell, for example for headless `claude -p` runs where `/plugin` is not available:

```bash
claude plugin marketplace add aphelion-labs/aphelion-skills
claude plugin install aphelion-sdlc@aphelion-skills
```

### How aphelion enables it

aphelion's `.claude/settings.json` declares the marketplace and turns the plugin on for everyone who works in the repository:

```json
{
  "extraKnownMarketplaces": {
    "aphelion-skills": {
      "source": { "source": "github", "repo": "aphelion-labs/aphelion-skills" }
    }
  },
  "enabledPlugins": {
    "aphelion-sdlc@aphelion-skills": true
  }
}
```

Two things from the docs to know:

- Claude Code honours `extraKnownMarketplaces` from a repository's settings only after you accept the workspace trust dialog for that folder.
- Enabling a plugin in project settings does not download it. Each collaborator runs `claude plugin install aphelion-sdlc@aphelion-skills --scope project` once.

## What the skills expect in the product repository

- `gh`, authenticated for aphelion-labs/aphelion.
- Node.js 20.19.0 or later, so `npx` can run OpenSpec 1.14.2 (its declared `engines`).
- `make check`, `scripts/check-specs.sh`, the issue forms in `.github/ISSUE_TEMPLATE/`, the pull request template in `.github/`, and the labels that aphelion's `scripts/github-setup.sh` creates.
- The OpenSpec version in the skills, 1.14.2, must match the one aphelion pins. Bump both in step (ADR 0004).

## Decisions

| Decision | Source |
|---|---|
| OpenSpec runs as `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2` | ADR 0004: OpenSpec used as-is and pinned. The exact pin and the telemetry setting are open decisions there; 1.14.2 is the version the 05 PoC verified, and aphelion's `.claude/settings.json` also sets `OPENSPEC_TELEMETRY=0`. |
| Change folder `openspec/changes/<N>-<slug>/`, with `Issue: #N` in `proposal.md` and in the change's goal; the branch name is used when it has that form | ADR 0004 (OpenSpec has no issue-link field); aphelion's `CLAUDE.md` names branches `<issue>-<slug>`. |
| MODIFIED deltas carry the full requirement with every scenario | ADR 0004 (OpenSpec quirk found in the 05 PoC). |
| Archive inside the same pull request, with `--yes`; tasks are checked by the skill because `--yes` only warns | ADR 0004. |
| Features and spec-wrong bugs get a change folder; code-wrong bugs and chores do not | ADR 0004. |
| `design.md` only for a non-obvious decision, with a draft ADR (`status: proposed`) for each | ADR 0001. |
| One pull request per issue: draft from issue-propose, ready from issue-finish, `Closes #N` | ADR 0010, ADR 0004. |
| Commit `docs: propose change for #N` and `docs: archive change for #N`; PR title `<type>(<cap>): <issue title in lowercase> (#N)` | Conventional Commits, terse and lowercase, no trailers (ADR 0010, aphelion's `CLAUDE.md`). The exact wording is the owner's brief of 2026-10-17. The scope of a title for a change that touches several capabilities is an open decision. |
| Rebase onto `origin/main` only when main changed a file the branch changed; push with `--force-with-lease`; never skip hooks | ADR 0005. |
| No handoff note for the review responder, anywhere | ADR 0010. |
| Never edit `openspec/specs/**` directly, including OpenSpec's own advice to edit a Purpose | ADR 0004. |
| Bodies are written with the Write tool and passed with `--body-file`, never through a heredoc | aphelion's `CLAUDE.md` (its Bash guard reads the whole command text). |
| Label names (`status:*`, `type:fix`, `origin:agent`, `cap:*`, `size:*`) | aphelion's `scripts/github-setup.sh` and the 2026-10-14 Blueprint. Not yet in an ADR. |
| Skills add status labels and never remove one | Open decision: whether a new status label replaces the old one. aphelion's pickup driver also sets status labels. |
| file-bug files at most three bugs per run | The 2026-10-14 Blueprint. Open decision until recorded in an ADR. |
| triage proposes a size only where size definitions are recorded | Open decision: aphelion's size labels say their thresholds are not decided. |
| triage never adds or removes a label, `status:needs-spec` included; its comment proposes labels as text and ends with "Owner: add status:needs-spec to approve, or reply with what is missing." | Owner decision of 2026-10-14: agents may create tickets but the owner reviews them. Only the owner moves an issue from `status:needs-triage` to `status:needs-spec`, which aphelion's pickup driver treats as approval (ADR 0010). |
| `allowed-tools` lists only the commands each skill's steps name | Claude Code docs: the field pre-approves those tools for the turn and restricts nothing. aphelion's headless runs pass their own allowlist. |
| Model invocation stays on (no `disable-model-invocation`) | file-bug has to fire in the middle of an implementation run, and the evals measure triggering. |
| `version` 0.1.0 is set in `plugin.json` only (and as the marketplace manifest's own version), not in the marketplace entry | Claude Code docs, "Release a new version": do not set it in both places. Bump it on every release, or users keep their cached copy. |

## Evals

`evals/` holds positive, negative and hard-rule cases for every skill, run with `claude plugin eval`. See [evals/README.md](evals/README.md) for the cases, the offline fixture they use, the exact commands, exit codes and the open decisions (threshold, runs, models, cost ceiling).
