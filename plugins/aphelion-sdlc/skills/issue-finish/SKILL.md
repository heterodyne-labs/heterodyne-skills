---
name: issue-finish
description: Finishes a aphelion pull request after the implementation is done on its branch. Ticks the OpenSpec tasks, runs make check, archives the change so the living spec updates inside the same PR, checks the specs gate, rewrites the PR body, marks the PR ready for review and labels the issue. Use when the implementation for an issue is complete, for example "finish issue #12", "wrap up this branch for review", "get the PR ready for review", "archive the change and mark the PR ready".
argument-hint: "[issue-number]"
allowed-tools: Read Glob Grep Bash(gh pr view *) Bash(gh pr edit * --body-file *) Bash(gh pr ready *) Bash(gh issue view *) Bash(gh issue edit * --add-label status:in-review) Bash(git status *) Bash(git branch --show-current) Bash(git fetch origin) Bash(git merge-base *) Bash(git diff *) Bash(git log *) Bash(git rebase origin/main) Bash(git rebase --continue) Bash(git add openspec/changes openspec/specs) Bash(git commit -m *) Bash(git push) Bash(git push --force-with-lease) Bash(make check) Bash(scripts/check-specs.sh *) Bash(OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 *) Edit(openspec/changes/**)
---

# issue-finish

Close out one issue's pull request after the implementation is done, in the same branch and the same pull request that issue-propose opened.

## When to use

- The implementation for an issue is complete on its branch and the owner or the loop asks you to finish it.

Do not use this skill to propose a change (use issue-propose) or to implement missing work. If work is missing, stop and say what is missing.

## Inputs

- The issue number N, from the skill argument, the request, or the pull request title, which ends in `(#N)`.
- The branch for that issue, checked out, with the implementation committed.

## Steps

1. Read the repository's `CLAUDE.md` and follow it. Where it disagrees with this skill, stop and tell the owner; do not choose between them.
2. Find the pull request and the change:
   - `gh pr view --json number,title,body,isDraft,url,headRefName` for the current branch. If there is none, stop and say so.
   - The change folder is `openspec/changes/N-<slug>/`, outside `openspec/changes/archive/`. If there is none, the ticket is a code-only bug or a chore and has no change folder (ADR 0004); skip steps 4, 6 and 7.
3. Rebase if main touched your files (ADR 0005). Run `git fetch origin`, then compare the files changed on both sides since the merge base:
   - `git diff --name-only $(git merge-base HEAD origin/main) HEAD`
   - `git diff --name-only $(git merge-base HEAD origin/main) origin/main`
   If any file is in both lists, run `git rebase origin/main` and resolve the conflicts so both sides' intent survives. The pre-push hook refuses the push otherwise. If two changes modify the same requirement under `openspec/`, stop and tell the owner; that needs a human (ADR 0004).
4. Check the tasks. Read `tasks.md` in the change folder. For every unticked task, confirm the work and its verification exist in the branch, then tick it (`- [x]`). If a task is not done, stop and report which ones remain. `archive --yes` only warns about unticked tasks, so this check is yours (ADR 0004).
5. Run `make check`. It must pass. If it fails, stop here: the implementation is not finished. Fix the cause outside this skill, then run this skill again from step 1. If the failure is outside this issue's scope, use the file-bug skill and report it.
6. Archive the change so the living spec updates inside this pull request (ADR 0004):
   `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 archive N-<slug> --yes`
   OpenSpec merges the delta into `openspec/specs/` and moves the folder to `openspec/changes/archive/<date>-N-<slug>/`. If the archive fails, stop and report the error; never repair the living spec by hand.
7. Commit the ticked tasks, the archived folder and the living spec as the archive left them, in one commit. Staging the archive's output is not an edit; never change those files yourself.
   - `git add openspec/changes openspec/specs`
   - Check with `git status --short` that nothing else is staged.
   - `git commit -m "docs: archive change for #N"`. Commit messages follow Conventional Commits, lowercase and terse, with no trailing period and no trailers or co-author lines (ADR 0010 and `CLAUDE.md`).
8. Run `scripts/check-specs.sh origin/main HEAD`. Read the script's usage line first and follow it if it differs. It must pass: living specs may change only together with an archived change.
9. Push with `git push`, or `git push --force-with-lease` when you rebased in step 3. If the pre-push hook refuses, follow its message: fetch, rebase onto `origin/main`, resolve, run `make check` again, and push with `--force-with-lease` (ADR 0005).
10. Rewrite the pull request body from the repository's pull request template in `.github/`. Remove "spec proposal, awaiting approval". Fill every section of the template, including these:
    - Summary: what the change does, in a few sentences, for the owner and the reviewers.
    - Issue: `Closes #N`.
    - Spec change: the archived folder path and the requirements it added, modified or removed per capability, or "none" for a ticket without a change folder.
    - How verified: the commands you ran and their results, including `make check` and `scripts/check-specs.sh`, and the tests that cover each scenario.
    - Decisions made: each design decision with a link to its ADR, or "none". A constant or non-obvious default with no spec requirement or ADR behind it is listed as "Open decision: ..." here, or recorded first as a new ADR with `status: proposed` (ADR 0001).
    Any other section, such as review notes, is written for the owner and the reviewers about the change itself. Write the body with the Write tool to a new file outside the working tree, for example in the system temporary directory, and run `gh pr edit <PR> --body-file <file>`. Never pass it through a shell heredoc or `echo`: the repository's Bash guard reads the whole command text (`CLAUDE.md`). Keep the title that issue-propose set.
11. Mark the pull request ready: `gh pr ready <PR>`.
12. Label the issue: `gh issue edit N --add-label status:in-review`. Do not remove other labels; whether a new status label replaces the old one is an open decision.
13. Stop. Report the pull request URL.

## Hard rules

- Never write a handoff note for a future responder: no handoff file, and no section in the pull request body, a commit message or the change folder addressed to whoever answers the reviews. The responder starts fresh and reads only what describes the change itself (ADR 0010).
- Never edit `openspec/specs/**` directly, with any tool, including Bash. The living spec changes only through `openspec archive` (ADR 0004). This includes OpenSpec's advice to edit a capability's Purpose directly; raise that with the owner instead.
- Never force-push without `--force-with-lease`.
- Never skip git hooks: no `--no-verify`, no `-n` on `git commit` or `git push`, no change to `core.hooksPath` (ADR 0005).
- Never mark the pull request ready while a task is unticked, `make check` fails, or `scripts/check-specs.sh` fails.
- Never implement new behaviour in this skill. Missing work means stop and report.

## Done when

- If main touched the same files, the branch is rebased onto `origin/main` and `make check` passed after the rebase.
- `make check` passed, and every task in `tasks.md` is ticked when the ticket has a change folder.
- When the ticket has a change folder, it is archived under `openspec/changes/archive/` and the living spec is updated by that archive in this branch.
- `scripts/check-specs.sh` passed.
- The branch is pushed without skipping hooks.
- The pull request body has the summary, issue, spec change, how verified and decisions made sections, with ADR links or "none".
- The pull request is ready for review and the issue carries `status:in-review`.
