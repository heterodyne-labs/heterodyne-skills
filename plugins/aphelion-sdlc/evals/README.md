# aphelion-sdlc evals

Eval cases for the four skills, in the format `claude plugin eval` reads (Claude Code docs, "Test plugins with evals", checked 2026-10-17). Each case is a directory with a `prompt.md` (run settings in front matter, the user's request as the body) and one grader per file under `graders/`. Cases that need a repository also have a `case.yaml` naming a `scaffold.sh`.

ADR 0012 requires evals for skills and CI that runs them. Every run and every `llm` grader is a real model call on whoever's credentials run the suite.

## Cases

| Skill | Positive (should trigger and act) | Negative (must not trigger) | Hard rule |
|---|---|---|---|
| issue-propose | `propose-writes-change-for-issue` | `propose-ignores-triage-request` | `propose-stops-before-implementation` |
| issue-finish | `finish-archives-and-marks-ready` | `finish-ignores-proposal-request` | `finish-never-edits-living-spec` |
| file-bug | `bug-files-out-of-scope-defect` | `bug-ignores-triage-request` | `bug-does-not-fix-in-branch`, `bug-files-at-most-three` |
| triage | `triage-comments-on-new-issue` | `triage-ignores-bug-report` | `triage-never-closes-or-relabels` |

Each case is tagged with its skill and with `positive`, `negative` or `hard-rule`, so `--tag` can select a subset.

Graders used: `tool_used` (the skill fired; a command such as `gh issue view 12` or `openspec@1.14.2 archive` ran, or never ran), `tool_order` (`make check` before the archive), `file_exists` (the archived change folder), `regex` (over files the run produced), and `llm` (short rubrics on the final reply or a posted body). A `tool_used` grader on `Skill` is reported as a plugin-fired indicator and does not count towards the score in a run that also has a no-plugin baseline; a "must not fire" grader sets `arm: both` so it does count (docs, "Score against the no-plugin baseline").

## How a run reaches GitHub: it does not

An eval run gets an empty workspace, a temporary home directory and only an allowlist of environment variables, and its shell commands run in Claude Code's OS sandbox (docs, "How runs are isolated", "Grant tools"). So `gh` has no login and no network there. The scaffold therefore builds an offline fixture:

- `_fixtures/repo.sh` builds a small stand-in for the aphelion repository: `CLAUDE.md`, `docs/`, one living spec (`openspec/specs/tui/spec.md`), snapshots of aphelion's issue forms and pull request template (`_fixtures/github/`), `scripts/check-specs.sh` (a snapshot of aphelion's), a `make check` that always passes, a local bare `origin`, and the branch `12-show-blocked-reason`.
- `_fixtures/gh` is copied to `.fixture/bin/gh`. It answers `issue view`, `issue list`, `pr view`, label listings and the write commands from local files, and records every call in `.fixture/gh-calls.log` and every body in `.fixture/gh-bodies.log`. Graders read those two files.
- The case's `append_system_prompt` tells Claude to run `.fixture/bin/gh` wherever it would run `gh`. The `tool_used` patterns match `gh ...` either way.

Everything in the fixture is test data, not product decisions. `_fixtures/github/` and `_fixtures/check-specs.sh` are snapshots taken on 2026-10-17; refresh them when aphelion's versions change.

## Requirements

From the docs unless noted:

- Claude Code 2.1.269 or later. These files were validated with 2.1.302.
- git 2.31 or later.
- On Linux, `bubblewrap` and `socat` for the sandbox that granted Bash runs in; on Ubuntu 24.04 and later, also the AppArmor profile from the sandboxing docs (the CI workflow installs both).
- `python3` for the scaffolds, and Node.js 20.19.0 or later for `npx` to run OpenSpec 1.14.2 (its declared `engines`, npm registry, 2026-10-17).

## Run locally

From the plugin root:

```bash
cd plugins/aphelion-sdlc
claude plugin eval . --scaffold --allow-tools Bash Write Edit "WebFetch(domain:registry.npmjs.org)"
```

- `--scaffold` runs each case's `scaffold.sh` as you, outside the sandbox, in the run's empty workspace. These scripts only build the fixture and warm the run's npm cache with OpenSpec; read them before you pass the flag (docs, "What a run can access").
- `--allow-tools Bash Write Edit` lets the skills run `git`, `make`, `npx` and the fixture `gh` and write the change folder. Granted Bash runs inside the OS sandbox, which confines writes to the run's workspace.
- `WebFetch(domain:registry.npmjs.org)` lets the sandboxed `npx` reach the npm registry if the warmed cache is not found.
- The first run in this directory asks `Trust this plugin directory?`.

One case, one run, no baseline, while iterating:

```bash
claude plugin eval . --case propose-writes-change-for-issue --runs 1 --ablation none --scaffold --allow-tools Bash Write Edit "WebFetch(domain:registry.npmjs.org)"
```

Put the target (`.`) first: `--tag`, `--allow-tools` and `--json` read the words after them as their values.

## Run in CI

`.github/workflows/evals.yml` runs:

```bash
claude plugin eval . \
  --scaffold \
  --trust-plugin \
  --model claude-opus-5-5 \
  --judge-model claude-haiku-5-5 \
  --no-publish \
  $EVALS_EXTRA_ARGS \
  --allow-tools Bash Write Edit "WebFetch(domain:registry.npmjs.org)" \
  --json results.json
```

with `CLAUDE_CODE_OAUTH_TOKEN` from the repository's secrets. `--trust-plugin` answers the trust prompt, which a run with `--json` or without a terminal cannot ask. `--json results.json` writes the result document (`schemaVersion: 1`, fields such as `aggregates.casesPassed` and `cases[].aggregates.score`). The job uploads `results.json` and `evals/results/` as an artifact.

Exit codes (docs, "Run evals in CI"):

| Code | Meaning |
|---|---|
| 0 | Every case scored at or above `--threshold`, and nothing else failed the run |
| 1 | A case below the threshold, a case file that failed to load, no cases found, a run that could not start or ended on an API error, an untrusted directory without `--trust-plugin`, an invalid option, or a `--json` file that could not be written |
| 2 | Partial run: the `--max-cost-usd` ceiling was hit, or the credential was rejected; `results.json` has `partial: true` |
| 130 | Interrupted |
| 143 | Terminated, for example by a CI timeout |

The eval job runs on manual dispatch only, until the owner sets the repository variable `EVALS_ENABLED` to `true`; then it also runs on pull requests from this repository. It draws on the owner's subscription.

## Decisions and open decisions

| Item | Value | Source |
|---|---|---|
| Model under test | `claude-opus-5-5` | The owner's instruction of 2026-10-17 that implementation runs use Opus 5.5. ADR 0011 still lists the implementers' model as an open decision; record it there. The docs advise pinning it in CI. |
| Judge model | `claude-haiku-5-5` | Open decision. Pins the CLI's default judge family (`--judge-model` defaults to haiku) so scores stay comparable. |
| Pass threshold | CLI default, 1.0 | Open decision (ADR 0012; the lecture's example used 90%). Set with `--threshold` in `EVALS_EXTRA_ARGS`. |
| Runs per case | CLI default, 3 | Open decision (ADR 0012). Set with `--runs`. |
| No-plugin baseline | CLI default, on | Open decision. It doubles the agent runs and never changes the exit code; `--ablation none` turns it off. |
| Cost ceiling | none | Open decision (ADR 0012: which credential pays). Set with `--max-cost-usd`. |
| `max_turns: 50`, `timeout_seconds: 900` in workflow cases | placeholders | Open decision. The defaults (10 turns, 300 s) are below what issue-propose's steps need: it names about two dozen tool calls, and the docs advise generous caps because hitting one counts as a run error. Negative cases keep the defaults. |
| Fixture numbers, names and dates | test data | Not product decisions; see `_fixtures/repo.sh`. |

In model calls, a full run is roughly (cases times runs) agent runs with the plugin, the same again for the baseline, plus three judge calls per `llm` grader per run (docs, "How a case is scored").

## Not verified

These files were checked for syntax and against the docs, and the scaffolds were run locally, but no eval was run (each run costs subscription usage). Not yet confirmed in a real run:

- that the sandboxed `npx` finds the OpenSpec cache the scaffold warmed. The docs give the scaffold the run's temporary home directory; that the agent sees the same one is assumed. Otherwise `npx` needs the `WebFetch(domain:registry.npmjs.org)` grant to reach the registry;
- that the Write tool may write a body file outside the workspace, as the skills ask; if not, a run may write it inside the workspace, which the fixture `gh` reads equally well;
- that the cases, nested two levels below `evals/`, load with their explicit `plugins: ["../../.."]` and that a scaffold can source `../../_fixtures/repo.sh` from its own directory (it could locally, run as `bash <case>/scaffold.sh` from an empty directory).
