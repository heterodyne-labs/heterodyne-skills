---
name: file-bug
description: Files a GitHub bug issue for a defect an agent finds outside the scope of the aphelion issue it is working on, using the repository's bug form, labelled type:fix, status:needs-triage and origin:agent, and linked to the current issue and pull request, without fixing it in the current branch. Use when you notice a bug, crash, regression or spec violation that is not part of your ticket, for example "this is out of scope, file it", "log this bug separately", "track this defect", "I found an unrelated bug".
allowed-tools: Read Glob Grep Bash(gh issue list *) Bash(gh issue view *) Bash(gh issue create *) Bash(gh pr view *) Bash(git branch --show-current) Bash(git rev-parse HEAD) Bash(git log *)
---

# file-bug

Record a defect you found outside your ticket as its own GitHub issue, then carry on with your ticket.

## When to use

- You are working on one issue and find a defect that is outside its scope: neither the issue's acceptance criteria nor its change folder's delta spec covers it.

Do not use it for a defect inside your issue's scope; that is part of your issue's work. Do not use it to triage someone else's issue (use triage).

## Inputs

- What you observed: the failure, the command or action that showed it, and the output.
- The issue N and pull request P you are working on, from the request, the branch's pull request (`gh pr view --json number,title,url`) or its title, which ends in `(#N)`.

## Steps

1. Read the repository's `CLAUDE.md` and follow it. Where it disagrees with this skill, stop and tell the owner; do not choose between them.
2. Keep count. You file at most three bugs per run, where a run is one agent session. The limit comes from the 2026-10-14 Blueprint and is an open decision until the owner records it in an ADR. If this would be the fourth, do not file it; list it in your final report for the owner instead.
3. Search for duplicates: `gh issue list --state open --search "<key words>"`, with the key words of the symptom and the affected command or capability. Open any likely match with `gh issue view`. If an open issue already describes the defect, do not file a new one; name the existing issue in your report.
4. Find the requirement the defect violates. Read the living spec of the affected capability under `openspec/specs/<capability>/spec.md` and name the requirement and scenario. If no requirement covers the behaviour, write that the spec is silent; the fix then needs a spec change (ADR 0004).
5. Read the bug form in `.github/ISSUE_TEMPLATE/` and use its field labels, in order, as `###` headings of the issue body, the way GitHub renders a submitted form. Fill every field; for a dropdown, use one of the form's options exactly. The form decides the fields; these are the ones aphelion's form asks for:
   - Description: what is wrong, in one or two sentences.
   - How discovered: "Found by an agent while working on #N (pull request #P)", plus what you were doing.
   - Reproducible: the form's option that matches what you saw.
   - Steps to reproduce: numbered, starting from a clean checkout.
   - Expected: the behaviour the cited requirement and scenario demand, with the spec path, or the form's wording for "no requirement covers it".
   - Spec impact: the form's option for code wrong, spec wrong or silent, or not sure (ADR 0004).
   - Actual: what happens instead, with the exact error or output.
   - Environment: the commit (`git rev-parse HEAD`), the branch, and the operating system and tool versions you know. Write "unknown" for anything you do not know.
   - Acceptance criteria: testable statements, starting from the form's default text, normally that the cited scenario passes as an automated regression test.
   - Definition of done: the form's default checklist.
   Write only what you observed. Do not guess a cause as fact; label a guess as a hypothesis.
6. Write the body with the Write tool to a new file outside the working tree, for example in the system temporary directory; never pass it through a shell heredoc or `echo`, because the repository's Bash guard reads the whole command text (`CLAUDE.md`). Create the issue: `gh issue create --title "<short statement of the defect>" --label type:fix --label status:needs-triage --label origin:agent --body-file <file>`. The `#N` and `#P` references in the body link the new issue to your current work.
7. Return to your ticket. Report the new issue's URL, and any defects you did not file because of the limit.

## Hard rules

- Never fix the bug in the current branch or pull request, and never start a branch for it. Only the owner moves the new issue forward from triage.
- Never file more than three bugs in one run (open decision, see step 2).
- Never add labels beyond `type:fix`, `status:needs-triage` and `origin:agent`, and never assign, close or edit other issues.
- Never invent a number, limit or default in the report. Cite the spec requirement, or say the spec is silent (ADR 0001).

## Done when

- The defect is filed once, with every bug form field filled, labelled `type:fix`, `status:needs-triage` and `origin:agent`, and referencing the current issue and pull request; or an existing open issue already covered it and you named it.
- The current branch contains no change for this defect.
- Your report lists the new issue URLs and any defects held back by the limit.
