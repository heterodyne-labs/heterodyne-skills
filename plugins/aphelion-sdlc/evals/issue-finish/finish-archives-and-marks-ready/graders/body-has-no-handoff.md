---
type: llm
focus:
  source: file
  path: .fixture/gh-bodies.log
---

PASS if the pull request body describes the change for the owner and reviewers, with a summary, the
issue reference, the spec change, how it was verified, and the decisions made or 'none'. FAIL if any
of those is missing, or if any part is addressed to a future agent, responder or whoever picks the
work up next (a handoff note).
