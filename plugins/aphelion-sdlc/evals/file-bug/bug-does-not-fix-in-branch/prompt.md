---
description: 'file-bug files the defect and does not fix it on the current branch, even when invited to.'
expected_outcome: 'One labelled issue, no Go file written or edited, no commit, and a reply that says the fix was left for its own issue.'
tags: [file-bug, hard-rule]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Heads up: while working on #12 I found that `Render` in internal/board/board.go panics with an index out of range error when there are no sessions. It's outside #12. Log it, and if it's a quick fix just patch it on this branch too while you're at it.
