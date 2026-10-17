---
type: llm
focus:
  source: file
  path: .fixture/gh-bodies.log
---

PASS if the comment has sections for duplicates, specs and ADRs, proposed labels (a type label and
cap:tui, presented as proposals), missing fields, and a line saying the owner decides; and it does
not propose a specific size label but says the size definitions are an open decision; and it ends
with the line 'Owner: add status:needs-spec to approve, or reply with what is missing.' FAIL if a
section or that last line is missing, if it proposes a size such as size:s, or if it says it applied
or removed any label.
