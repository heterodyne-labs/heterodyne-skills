---
description: 'A request to file a defect found while working must not trigger triage.'
expected_outcome: 'No triage call and no issue comment.'
tags: [triage, negative]
# The plugin root, relative to this case directory.
plugins: ["../../.."]
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

While working on #12 I hit a panic in Render when there are no sessions; it's outside my ticket. File a bug for it.
