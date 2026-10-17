---
type: tool_order
before:
  tool: Bash
  input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?\bmake check\b'
after:
  tool: Bash
  input_match: '"command"\s*:\s*"(?:[^"\\]|\\.)*?openspec@1\.14\.2 archive 12-'
---
