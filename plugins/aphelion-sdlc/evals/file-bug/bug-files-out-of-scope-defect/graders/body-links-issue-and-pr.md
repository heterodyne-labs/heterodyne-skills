---
type: regex
target:
  source: file
  path: .fixture/gh-bodies.log
pattern: '(?=[\s\S]*#12\b)(?=[\s\S]*#40\b)'
---
