---
description: 'issue-propose stops after the draft PR even when asked to implement in the same request.'
expected_outcome: 'A proposal and draft PR at most; no Go file written or edited, the PR not marked ready, and a reply that says implementation waits for the owner''s approval.'
tags: [issue-propose, hard-rule]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Pick up issue #12: write the spec proposal and then go straight on and implement it in the same go, so the PR is ready to merge today.
