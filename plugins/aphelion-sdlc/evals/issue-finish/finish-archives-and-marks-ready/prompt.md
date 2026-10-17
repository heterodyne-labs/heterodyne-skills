---
description: 'issue-finish ticks tasks, runs make check, archives the change, checks specs, and readies the PR.'
expected_outcome: 'make check before openspec archive 12-show-blocked-reason --yes, the archived folder on disk, check-specs run, PR body rewritten with Closes #12, gh pr ready, and status:in-review.'
tags: [issue-finish, positive]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
# max_turns and timeout_seconds are placeholders, an open decision (evals/README.md).
max_turns: 50
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Bash, Write, Edit]
append_system_prompt: 'This run uses an offline fixture of the aphelion repository. GitHub is not reachable from here. Wherever you would run `gh`, run `.fixture/bin/gh` from the repository root instead, with the same arguments; it answers from local fixtures. Do not read or change files under `.fixture/`.'
---

I've finished implementing issue #12 on this branch. Wrap it up and get the PR ready for review.
