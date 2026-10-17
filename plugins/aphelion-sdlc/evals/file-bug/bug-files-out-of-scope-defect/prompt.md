---
description: 'file-bug searches for duplicates and files one labelled bug linked to #12 and PR #40.'
expected_outcome: 'gh issue list --search, then one gh issue create with type:fix, status:needs-triage and origin:agent, a body citing the Empty board requirement and #12 and #40, and no code change.'
tags: [file-bug, positive]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

While implementing #12 on this branch I noticed that `Render` in internal/board/board.go panics with an index out of range error when there are no sessions. That's not part of #12. Get it tracked properly.
