---
name: issue-propose
description: Turns one aphelion GitHub issue into an OpenSpec change proposal (proposal, tasks, delta specs) and opens it as a draft pull request for the owner to approve, without writing any implementation. Use when asked to propose, spec out, write up or plan an issue before coding, for example "propose a change for issue #12", "write the spec proposal for #12", "draft the OpenSpec change for this ticket", "spec out issue 12 for review".
argument-hint: "[issue-number]"
allowed-tools: Read Glob Grep Bash(gh issue view *) Bash(gh pr view *) Bash(gh pr create --draft *) Bash(gh issue comment * --body-file *) Bash(gh issue edit * --add-label status:spec-review) Bash(gh issue edit * --add-label status:blocked) Bash(git status *) Bash(git branch --show-current) Bash(git add openspec/changes/*) Bash(git add docs/decisions/*) Bash(git commit -m *) Bash(git push -u origin HEAD) Bash(OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 *) Write(openspec/changes/**) Edit(openspec/changes/**) Write(docs/decisions/**) Edit(docs/decisions/**)
---

# issue-propose

Write the spec change for one issue, put it up as a draft pull request, and stop. The owner approves the proposal before anyone implements it.

## When to use

- The owner asks you to propose, spec or plan a GitHub issue of the aphelion repository.
- The issue is a feature, or a bug where the spec is wrong or silent. Both need a change folder (ADR 0004).

Do not use this skill to implement, to finish a pull request (use issue-finish), to triage a new issue (use triage), or to report a defect you found while working (use file-bug).

## Inputs

- The issue number N, from the skill argument or the request. Accept `12` or `#12`. If there is no number, ask for it and stop.
- A checkout of the aphelion repository on the branch prepared for this issue.

## Steps

1. Read the repository's `CLAUDE.md` and follow it. Where it disagrees with this skill, stop and tell the owner; do not choose between them.
2. Run `git branch --show-current`. If the branch is `main`, stop and say so. Work happens on the issue's own branch, named as the repository's `CLAUDE.md` says and created before this skill runs, for example by the pickup step.
3. Read the issue: `gh issue view N --comments`. Note its title, body, labels and state. If it is closed, stop and say so.
4. Check for earlier work. If `gh pr view` shows an open pull request for this branch, or a folder `openspec/changes/N-*` already exists, stop and report it instead of proposing twice.
5. Read the context:
   - `docs/product/overview.md`.
   - The living specs: list capabilities with `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 list --specs`, then read every spec the issue touches in full with `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 show <capability> --type spec`.
   - `docs/decisions/README.md` and every ADR whose subject the issue touches. ADR 0001 and ADR 0004 always apply.
6. Decide whether you can propose. Post a blocking comment and stop (step 7) if any of these holds:
   - The issue has no acceptance criteria, or they cannot be tested.
   - The issue contradicts a requirement in `openspec/specs/` without saying it wants that requirement changed. An issue that asks to change a requirement is not a conflict; that is what a MODIFIED or REMOVED delta is for.
   - The issue contradicts an ADR, accepted or proposed. Changing an ADR needs a new ADR from the owner (ADR 0001).
   - The issue needs a value or default that no spec requirement or ADR gives and the issue does not state. Do not pick one (ADR 0001).
7. To block: write the questions as a numbered list, each naming the spec requirement, ADR or missing field it comes from. Post them with `gh issue comment N --body-file <file>` (see "Bodies" below). Then run `gh issue edit N --add-label status:blocked` and stop.
8. Check the ticket kind against ADR 0004. A bug whose cited requirement is correct as written (the code is wrong) and a chore need no change folder. For those, comment on the issue that no spec change is needed under ADR 0004, and stop without a pull request. The owner decides the next step.
9. Choose the change name `N-<slug>`. When the current branch already has that form for issue N, use the branch name exactly; the pickup step names the branch and the change the same. Otherwise the slug is the issue title in lowercase kebab-case, shortened to its key words. Create the folder with OpenSpec, never by hand:
   `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 new change N-<slug> --goal "Issue: #N" --description "<issue title>"`
   OpenSpec has no issue-link field, so the issue number lives in the folder name, in the goal, and in `proposal.md` (ADR 0004).
10. For each artifact, get OpenSpec's own template first with `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 instructions <proposal|specs|tasks|design> --change N-<slug>`, then write the file. Where OpenSpec's instructions conflict with the hard rules below, the hard rules win.
    - `proposal.md`: the first line is `Issue: #N`. Then the sections OpenSpec asks for: why, what changes, capabilities, impact.
    - Delta specs at `specs/<capability>/spec.md` inside the change folder, one per capability, using the exact capability path from `openspec/specs/`. Use `## ADDED Requirements`, `## MODIFIED Requirements` and `## REMOVED Requirements`. Every requirement uses SHALL and has at least one `#### Scenario:` with WHEN and THEN. A MODIFIED block carries the full replacement requirement, copied whole from the living spec with all its scenarios and then edited; partial text drops scenarios at archive (ADR 0004). A REMOVED block gives a reason and a migration.
    - `tasks.md`: a checklist in OpenSpec's `- [ ] X.Y` format derived from the issue's acceptance criteria. Every acceptance criterion maps to at least one task, and each task says how it is verified.
    - `design.md`: write it only when the change needs a decision that is not obvious from the issue, the specs and the ADRs. Every such decision also gets a draft ADR (next step).
11. When you wrote `design.md`, write a draft ADR for each decision in it: `docs/decisions/NNNN-kebab-title.md` with the next free number, the same MADR layout as the existing ADRs, `status: proposed`, and the options considered and rejected. Add its row to the table in `docs/decisions/README.md`. A value you cannot trace to a spec requirement or an ADR is written as "Open decision: ..." and never chosen (ADR 0001).
12. Validate: `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 validate N-<slug> --strict --no-interactive`. Fix the change folder until it passes. Never weaken a requirement or invent one just to pass validation.
13. Commit the change folder only, plus the draft ADR files and the README row when you wrote them:
    - `git add openspec/changes/N-<slug>`, and when you wrote draft ADRs, `git add docs/decisions/<file>` for each of them and for `docs/decisions/README.md`.
    - Check with `git status --short` that nothing else is staged.
    - `git commit -m "docs: propose change for #N"`. Commit messages follow Conventional Commits, lowercase and terse, with no trailing period and no trailers or co-author lines (ADR 0010 and `CLAUDE.md`).
14. Push with `git push -u origin HEAD`. If the pre-push hook refuses, follow its message: fetch, rebase onto `origin/main`, resolve, and push again with `git push --force-with-lease` (ADR 0005).
15. Open a draft pull request against `main`:
    - Title: `<type>(<cap>): <issue title in lowercase> (#N)`. The type is `feat` for new or changed behaviour and `fix` for a bug (Conventional Commits, ADR 0010). The cap is the capability whose spec the change touches, which matches the issue's `cap:` label when it has one. If the change touches more than one capability, use the issue's `cap:` label and name every capability in the body; the scope of a multi-capability title is an open decision.
    - Body: read the repository's pull request template in `.github/` and fill every section. The summary starts with "spec proposal, awaiting approval". The issue section says `Closes #N`, because the same pull request carries the implementation later (ADR 0004, ADR 0010). The spec change section names the change folder. Every section is written for the owner and the reviewers, never as a note to a later agent (ADR 0010).
    - Run `gh pr create --draft --base main --title "<title>" --body-file <file>` (see "Bodies" below).
16. Label the issue: `gh issue edit N --add-label status:spec-review`. Do not remove other labels; whether a new status label replaces the old one is an open decision.
17. Stop. Report the pull request URL and the change folder path.

## Bodies

Write every issue comment and pull request body with the Write tool to a new file outside the working tree, for example in the system temporary directory, and pass it with `--body-file <file>`. Never pass a body through a shell heredoc or `echo`: the repository's Bash guard reads the whole command text (`CLAUDE.md`).

## Hard rules

- Planning boundary: never write or change code, tests, build files or any other file in the working tree outside the change folder, the draft ADR files and their row in `docs/decisions/README.md`. Stop once the draft pull request exists, even if the request also asks you to implement. Implementation is a separate run after the owner approves the proposal (ADR 0010).
- Never edit `openspec/specs/**`. The living spec changes only through `openspec archive` in issue-finish (ADR 0004). This includes OpenSpec's advice to edit a capability's Purpose directly; raise that with the owner instead.
- Never invent a number, limit, timeout, threshold or default. Trace it to a spec requirement or an ADR, or write it as "Open decision: ..." (ADR 0001).
- Never set an ADR's status to accepted. Only the owner does (ADR 0001).
- Never skip git hooks: no `--no-verify`, no `-n` on `git commit` or `git push`, no change to `core.hooksPath` (ADR 0005).
- Never force-push without `--force-with-lease`.
- Never mark the pull request ready for review. It stays a draft until issue-finish.

## Done when

Either:

- `openspec/changes/N-<slug>/` passes `validate --strict`; it holds `proposal.md` starting with `Issue: #N`, `tasks.md` covering every acceptance criterion, and delta specs, plus `design.md` and draft ADRs only where a decision needed them;
- one commit holds only those files, and the branch is pushed;
- a draft pull request with the title format above and "spec proposal, awaiting approval" in its body is open;
- the issue carries `status:spec-review`;
- no code changed.

Or the issue carries `status:blocked` with one comment listing the questions, or a comment saying no spec change is needed, and nothing else changed.
