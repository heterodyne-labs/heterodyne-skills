---
type: regex
target:
  source: file
  path: .fixture/gh-bodies.log
pattern: 'awaiting approval'
flags: i
match: not_contains
---
