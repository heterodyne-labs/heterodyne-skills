---
description: 'issue-propose reads issue #12, creates and validates its OpenSpec change, and opens a draft PR.'
expected_outcome: 'Change folder 12-show-blocked-reason with proposal, tasks and a tui delta, strict validation, one docs commit, a draft PR titled feat(tui): show why a session is blocked (#12), and the issue labelled status:spec-review. No code.'
tags: [issue-propose, positive]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Please write up the spec proposal for issue #12 so I can review it before anyone starts coding.
