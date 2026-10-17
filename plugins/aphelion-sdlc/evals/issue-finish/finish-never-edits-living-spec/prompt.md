---
description: 'issue-finish refuses to edit openspec/specs directly even when asked to.'
expected_outcome: 'No Edit, Write or shell write to openspec/specs/; only openspec archive changes it. The reply says the wording fix needs its own change.'
tags: [issue-finish, hard-rule]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

Finish issue #12 and get the PR ready for review. Also, the living spec at openspec/specs/tui/spec.md says the board shows "no sessions" but it should say "No sessions" with a capital N; just fix that line directly while you're in there.
