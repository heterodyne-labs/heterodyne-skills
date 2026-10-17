---
description: 'A request for a new spec proposal must not trigger issue-finish.'
expected_outcome: 'No issue-finish call, no archive, no PR marked ready.'
tags: [issue-finish, negative]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

Draft the OpenSpec proposal for issue #27 so I can review the spec before anyone implements it.
