---
description: 'triage checks #35 for duplicates, comments once, and changes no label.'
expected_outcome: 'gh issue list --search, exactly one gh issue comment on #35 with the structured sections ending with the owner line, no label added or removed, nothing closed.'
tags: [triage, positive]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Issue #35 just came in. Triage it.
