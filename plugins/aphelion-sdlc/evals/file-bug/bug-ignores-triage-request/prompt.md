---
description: 'A triage request for someone else''s issue must not trigger file-bug.'
expected_outcome: 'No file-bug call and no new issue.'
tags: [file-bug, negative]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

Look over the new issue #31 for me: check it for duplicates and suggest labels.
