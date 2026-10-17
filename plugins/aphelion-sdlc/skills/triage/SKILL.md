---
name: triage
description: Triages a new aphelion GitHub issue for the owner. Checks for duplicates, checks it against the living specs and the ADRs, proposes type, cap and size labels as text, notes missing form fields, and posts one structured comment. It never adds or removes a label; the owner decides and approves. Use when a new issue needs a first look, for example "triage issue #31", "look over the new issue", "check #31 for duplicates and suggest labels".
argument-hint: "[issue-number]"
allowed-tools: Read Glob Grep Bash(gh issue view *) Bash(gh issue list *) Bash(gh issue comment * --body-file *) Bash(gh api --paginate repos/{owner}/{repo}/labels *) Bash(OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 *)
---

# triage

Give the owner a structured first look at one new issue. You propose; the owner decides.

## When to use

- A new issue in the aphelion repository needs triage, and the owner or the loop asks for it.

Do not use it to file a bug you found (use file-bug), to write a spec proposal (use issue-propose), or to change the repository.

## Inputs

- The issue number N, from the skill argument or the request. Accept `31` or `#31`. If there is no number, ask for it and stop.

## Steps

1. Read the repository's `CLAUDE.md` and follow it. Where it disagrees with this skill, stop and tell the owner; do not choose between them.
2. Read the issue: `gh issue view N --comments`. Note its title, body, labels and which issue form it came from.
3. Search for duplicates in open and closed issues: `gh issue list --state all --search "<key words>"`, using the key words of the issue's title and symptom. Open each likely match with `gh issue view`. A closed match may mean the issue was already fixed or rejected; say which.
4. Check it against the specs and the ADRs:
   - List capabilities with `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 list --specs` and read each spec the issue touches with `OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 show <capability> --type spec`.
   - Read `docs/decisions/README.md` and every ADR whose subject the issue touches.
   - Note each requirement the issue would change, and each requirement or ADR it contradicts. For a bug, note whether the cited requirement is correct as written (the code is wrong) or wrong or silent (the spec needs a change), as ADR 0004 distinguishes.
5. Check the fields. Read the issue form in `.github/ISSUE_TEMPLATE/` that matches the issue and list every field it marks as required that the issue leaves empty or unclear. An issue with no testable acceptance criteria is incomplete.
6. Propose labels from the labels that exist. List them with `gh api --paginate repos/{owner}/{repo}/labels --jq '.[] | [.name, .description] | @tsv'`.
   - `type:`: one existing type label, with the reason.
   - `cap:`: the capability whose spec the issue changes, matching a folder under `openspec/specs/` and an existing `cap:` label. If none fits, say so; a new capability is the owner's call.
   - `size:`: the definition of each size is an open decision. Propose a size only if the definitions are recorded, in the label descriptions, `CLAUDE.md` or an ADR, and cite where. Otherwise write "size: not proposed, the size definitions are an open decision".
7. Post exactly one comment. Write it with the Write tool to a new file outside the working tree, for example in the system temporary directory, and run `gh issue comment N --body-file <file>`. Never pass it through a shell heredoc or `echo`: the repository's Bash guard reads the whole command text (`CLAUDE.md`). Use these headings:
   - Duplicates: the matches with links, or "none found" with the search you ran.
   - Specs and ADRs: the requirements it would change, any conflicts, and the ADRs that apply.
   - Proposed labels: type, cap and size, each with its reason. These are proposals; you did not apply them.
   - Missing fields: each missing or unclear required field, or "none".
   - Decision: "The owner decides the labels, the priority and the next step."
   End the comment with this line, exactly: "Owner: add status:needs-spec to approve, or reply with what is missing."
8. Stop. Report the comment URL. Do not touch the labels: only the owner moves an issue from `status:needs-triage` to `status:needs-spec`, and the pickup driver treats `status:needs-spec` as approval (owner decision of 2026-10-14, ADR 0010).

## Hard rules

- The owner decides. Never close, reopen, lock, transfer or assign the issue, and never edit its title or body.
- Never add or remove any label, `status:needs-spec` included. Every label is a proposal in the comment.
- Post exactly one comment per triage.
- Never change the repository: no edits to tracked files, commits, branches or pull requests. The only file you write is the comment body, outside the working tree.
- Never invent a size definition, priority, limit or default. Cite where it is recorded, or call it an open decision (ADR 0001).

## Done when

- The issue has exactly one new comment with the duplicates, specs and ADRs, proposed labels, missing fields and decision sections, ending with the owner line from step 7.
- Its labels are unchanged.
- Nothing else in the repository or on GitHub changed.
