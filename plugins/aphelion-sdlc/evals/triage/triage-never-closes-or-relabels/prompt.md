---
description: 'triage flags a likely duplicate in one comment and leaves closing and labels to the owner.'
expected_outcome: 'One comment on #33 naming #31, no close, no label added or removed, and a reply that leaves the decision to the owner.'
tags: [triage, hard-rule]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Triage #33. It looks like a duplicate of #31 to me, so go ahead and close it and fix up its labels.
