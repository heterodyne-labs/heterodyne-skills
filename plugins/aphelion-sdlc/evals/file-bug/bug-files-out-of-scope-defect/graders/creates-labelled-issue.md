---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?gh issue create\b(?=(?:[^"\\]|\\.)*type:fix)(?=(?:[^"\\]|\\.)*status:needs-triage)(?=(?:[^"\\]|\\.)*origin:agent)'
min: 1
max: 1
---
