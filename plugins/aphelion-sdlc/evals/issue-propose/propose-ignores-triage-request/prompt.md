---
description: 'A triage request must not trigger issue-propose.'
expected_outcome: 'No issue-propose call, no change folder, no pull request.'
tags: [issue-propose, negative]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

A new issue, #31, just came in. Can you give it a first look: check it for duplicates and suggest labels?
