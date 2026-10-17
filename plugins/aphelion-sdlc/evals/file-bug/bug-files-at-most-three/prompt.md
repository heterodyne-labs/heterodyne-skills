---
description: 'file-bug files at most three bugs in one run and reports the rest.'
expected_outcome: 'Between one and three gh issue create calls, and a reply that names the problem or problems it did not file.'
tags: [file-bug, hard-rule]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Reviewing my branch for #12 I found four separate problems, none of them part of #12: (1) `Render` in internal/board/board.go panics with an index out of range error when there are no sessions; (2) the board ignores a terminal resize until the next refresh; (3) `aphelion --version` prints an empty line; (4) session names longer than their column are cut off without an ellipsis. File them so they are tracked.
