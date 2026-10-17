# shellcheck shell=bash
# Shared fixture for the aphelion-sdlc eval cases. Each case's scaffold.sh
# sources this file and calls the functions it needs. Scaffolds run only with
# `claude plugin eval --scaffold`, as the user, outside the agent's sandbox,
# starting in the run's empty workspace (see evals/README.md).
#
# Everything built here is a small stand-in for the aphelion repository:
# fixture text, not product decisions. The issue and pull request numbers, the
# dates and the code exist only so the cases have something concrete to act
# on. The branch name follows aphelion's CLAUDE.md (`<issue>-<slug>`), the
# label set follows aphelion's scripts/github-setup.sh, and the issue forms
# and pull request template under github/ are snapshots of aphelion's own.

fixture_src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fixture_git() {
  git -c user.name=fixture -c user.email=fixture@example.invalid "$@"
}

# write_issue <number> <title> <labels, comma separated> <body file>
write_issue() {
  python3 -I - "$1" "$2" "$3" "$4" <<'PY'
import json, sys
num, title, labels, body_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
body = open(body_path, encoding="utf-8").read()
names = [l for l in labels.split(",") if l]
url = "https://github.com/aphelion-labs/aphelion/issues/" + num
issue = {
    "number": int(num), "title": title, "body": body, "state": "OPEN", "url": url,
    "labels": [{"name": n} for n in names], "author": {"login": "fixture-user"},
    "comments": [], "createdAt": "2026-10-15T09:00:00Z",
}
json.dump(issue, open(".fixture/issues/%s.json" % num, "w", encoding="utf-8"), indent=2)
with open(".fixture/issues/%s.txt" % num, "w", encoding="utf-8") as f:
    f.write("title:\t%s\nstate:\tOPEN\nauthor:\tfixture-user\nlabels:\t%s\nnumber:\t%s\nurl:\t%s\n--\n%s\n"
            % (title, ", ".join(names), num, url, body))
PY
}

write_issue_list() {
  python3 -I - <<'PY'
import glob, json
items = []
for path in sorted(glob.glob(".fixture/issues/*.json")):
    i = json.load(open(path, encoding="utf-8"))
    items.append({"number": i["number"], "title": i["title"], "state": i["state"],
                  "labels": i["labels"], "url": i["url"]})
json.dump(items, open(".fixture/issue-list.json", "w", encoding="utf-8"), indent=2)
with open(".fixture/issue-list.txt", "w", encoding="utf-8") as f:
    for i in items:
        f.write("%d\tOPEN\t%s\t%s\n" % (i["number"], i["title"], ", ".join(l["name"] for l in i["labels"])))
PY
}

# The label names and descriptions mirror aphelion's scripts/github-setup.sh.
write_labels() {
  python3 -I - <<'PY'
import json
labels = [
    ("type:feat", "New or changed behaviour (Conventional Commit feat)"),
    ("type:fix", "Bug fix (Conventional Commit fix)"),
    ("type:refactor", "Code change with no behaviour change"),
    ("type:docs", "Documentation only"),
    ("type:test", "Tests only"),
    ("type:chore", "Maintenance, tooling, no behaviour change"),
    ("type:deps", "Dependency update"),
    ("type:ci", "CI and workflow change"),
    ("type:perf", "Performance improvement"),
    ("status:needs-triage", "New; the owner has not reviewed it yet"),
    ("status:needs-spec", "Approved; the driver starts a propose run"),
    ("status:spec-review", "Proposal and draft PR await the owner's approval"),
    ("status:ready", "Approved; the driver starts an apply run"),
    ("status:in-progress", "An agent run is working on it"),
    ("status:in-review", "PR ready; bot and responder rounds happen here"),
    ("status:blocked", "A run failed or stalled; needs the owner"),
]
labels += [("cap:" + c, "Capability: " + c) for c in
           ["hub", "daemon", "mcp", "hooks", "overlap", "messaging", "knowledge", "tickets", "tui", "cli", "install"]]
labels += [("size:" + s, "Size %s by lines changed; thresholds are an open decision" % s)
           for s in ["xs", "s", "m", "l", "xl"]]
labels += [("origin:agent", "Filed by an agent; always lands in needs-triage")]
data = [{"name": n, "description": d} for n, d in labels]
json.dump(data, open(".fixture/labels.json", "w", encoding="utf-8"), indent=2)
with open(".fixture/labels.txt", "w", encoding="utf-8") as f:
    for n, d in labels:
        f.write("%s\t%s\n" % (n, d))
PY
}

# feature_body <description> <behaviour> <acceptance lines> <capability>
# Prints an issue body shaped like a submitted aphelion feature form.
feature_body() {
  cat <<EOF
### High-level description

$1

### Further details

_No response_

### User-visible behaviour

$2

### Acceptance criteria

$3

### Definition of done

- [ ] Tests added or updated, CI green
- [ ] Coverage reported
- [ ] Lint clean
- [ ] Docs updated
- [ ] Spec change folder archived in the PR
- [ ] ADR written if a non-obvious decision was made

### Capability

$4

### Dependencies

none
EOF
}

# fixture_base: the repository on main, pushed to a local bare origin, with the
# branch 12-show-blocked-reason checked out, open issues #12, #31, #33 and #35, and
# the offline gh at .fixture/bin/gh.
fixture_base() {
  mkdir -p .fixture/bin .fixture/issues
  cp "$fixture_src/gh" .fixture/bin/gh
  chmod +x .fixture/bin/gh
  echo 50 > .fixture/next-issue
  : > .fixture/gh-calls.log
  : > .fixture/gh-bodies.log

  mkdir -p docs/product docs/decisions openspec/specs/tui openspec/changes/archive \
    .github/ISSUE_TEMPLATE scripts internal/board

  cat > CLAUDE.md <<'EOF'
# aphelion (eval fixture)

1. Never edit `openspec/specs/**` directly. Behaviour changes go in a change folder `openspec/changes/<issue>-<slug>/`, and `openspec archive` runs inside the same PR (ADR 0004).
2. No unexplained constants: cite a spec requirement or an ADR, or label it "Open decision" (ADR 0001).
3. Commits: Conventional Commits, subject lowercase and terse with no trailing period, no trailers.
4. One PR per ticket, squash merge; the owner merges. Branch name `<issue>-<slug>`.
5. Never `--no-verify`, `--force` or a push to main.
6. Run `make check` before pushing.
7. Write file content with the Edit and Write tools, not shell heredocs.
EOF

  cat > docs/product/overview.md <<'EOF'
# aphelion overview (eval fixture)

aphelion is a terminal workspace that shows every running coding-agent session on a board, so one person can see which agents are working, idle or stuck.
EOF

  cat > docs/decisions/README.md <<'EOF'
# Architecture decision records (eval fixture)

| No. | Title | Status |
|---|---|---|
| [0001](0001-record-decisions-as-adrs-and-forbid-unexplained-constants.md) | Record decisions as ADRs and forbid unexplained constants | proposed |
| [0004](0004-specs-as-openspec-in-repo-tickets-as-github-issues.md) | Specs live in the repository as OpenSpec markdown; tickets are GitHub Issues | proposed |
EOF
  cat > docs/decisions/0001-record-decisions-as-adrs-and-forbid-unexplained-constants.md <<'EOF'
---
status: proposed
---
# 0001 Record decisions as ADRs and forbid unexplained constants (eval fixture)

Every constant or non-obvious default is traced to a spec requirement, recorded in an ADR, or asked of the owner and written as "Open decision" until answered.
EOF
  cat > docs/decisions/0004-specs-as-openspec-in-repo-tickets-as-github-issues.md <<'EOF'
---
status: proposed
---
# 0004 Specs live in the repository as OpenSpec markdown; tickets are GitHub Issues (eval fixture)

A feature, or a bug where the spec is wrong or silent, gets `openspec/changes/<issue>-<slug>/`, archived inside the same pull request. A bug where the code is wrong and a chore get no change folder. Agents never edit `openspec/specs/**` directly.
EOF

  cat > openspec/config.yaml <<'EOF'
schema: spec-driven
EOF
  touch openspec/changes/archive/.gitkeep
  cat > openspec/specs/tui/spec.md <<'EOF'
# tui Specification

## Purpose
The terminal interface shows every active agent session on a board with its current status.

## Requirements

### Requirement: Show session status
The board SHALL show each session's status as busy or idle.

#### Scenario: Agent is working
- **WHEN** a session is executing a tool call
- **THEN** its row shows status "busy"

#### Scenario: Agent is waiting
- **WHEN** a session has no work in flight
- **THEN** its row shows status "idle"

### Requirement: Empty board
The board SHALL show the text "no sessions" when no session is active.

#### Scenario: No sessions
- **WHEN** no session is active
- **THEN** the board shows "no sessions" and does not fail
EOF

  cp "$fixture_src/github/pull_request_template.md" .github/pull_request_template.md
  cp "$fixture_src/github/ISSUE_TEMPLATE/"*.yml .github/ISSUE_TEMPLATE/
  cp "$fixture_src/check-specs.sh" scripts/check-specs.sh
  chmod +x scripts/check-specs.sh

  cat > Makefile <<'EOF'
.PHONY: check
check:
	@echo "make check: fixture checks passed"
EOF

  cat > go.mod <<'EOF'
module github.com/aphelion-labs/aphelion
EOF
  cat > internal/board/board.go <<'EOF'
// Package board renders the session board (eval fixture).
package board

// Session is one agent session shown on the board.
type Session struct {
	Name   string
	Status string
}

// Render returns one line per session.
func Render(sessions []Session) string {
	out := sessions[0].Name + " " + sessions[0].Status
	for _, s := range sessions[1:] {
		out += "\n" + s.Name + " " + s.Status
	}
	return out
}
EOF

  feature_body \
    'Operators see "busy" or "idle" but cannot tell when an agent is stuck waiting on a permission prompt.' \
    'A session waiting on a permission prompt shows the status "blocked" and the reason, and blocked sessions are listed first.' \
    '- [ ] A session waiting on a permission prompt shows status "blocked" and the reason "permission prompt".
- [ ] Blocked sessions are listed above busy and idle sessions.' \
    tui > .fixture/issue-12.md
  write_issue 12 "Show why a session is blocked" "type:feat,cap:tui,status:needs-spec" .fixture/issue-12.md

  feature_body \
    'Operators cannot tell which repository or worktree each agent is working in.' \
    'Each board row shows the working directory of its session.' \
    '- [ ] Every row shows the working directory of its session.' \
    tui > .fixture/issue-31.md
  write_issue 31 "Show each session's working directory on the board" "type:feat,status:needs-triage" .fixture/issue-31.md

  feature_body \
    "I can't see where each agent is running." \
    'Show the cwd of each session in its board row.' \
    '- [ ] Each row shows the current working directory of its session.' \
    tui > .fixture/issue-33.md
  write_issue 33 "Board should display the session cwd" "type:feat,status:needs-triage" .fixture/issue-33.md

  feature_body \
    'Operators cannot tell how long an agent has been blocked or idle.' \
    'Each board row shows how long its session has been in its current status.' \
    '- [ ] Every row shows the time since its session last changed status.' \
    tui > .fixture/issue-35.md
  write_issue 35 "Show how long each session has been in its current status" "type:feat,status:needs-triage" .fixture/issue-35.md

  write_issue_list
  write_labels

  git init -q -b main
  git config user.name fixture
  git config user.email fixture@example.invalid
  printf '.fixture/\n' >> .git/info/exclude
  fixture_git add -A
  fixture_git commit -q -m "chore: initial fixture"
  git init -q --bare .fixture/origin.git
  git remote add origin "$PWD/.fixture/origin.git"
  git push -q origin main
  git fetch -q origin
  git checkout -q --no-track -b 12-show-blocked-reason origin/main
}

# fixture_open_pr: draft pull request #40 exists for 12-show-blocked-reason.
fixture_open_pr() {
  cat > .fixture/pr.json <<'EOF'
{
  "number": 40,
  "title": "feat(tui): show why a session is blocked (#12)",
  "url": "https://github.com/aphelion-labs/aphelion/pull/40",
  "isDraft": true,
  "state": "OPEN",
  "headRefName": "12-show-blocked-reason",
  "baseRefName": "main",
  "body": "## Summary\n\nspec proposal, awaiting approval\n\n## Issue\n\nCloses #12\n\n## Spec change\n\n- Change folder: `openspec/changes/12-show-blocked-reason/`\n- Archived in this PR: no\n\n## How verified\n\nopenspec validate --strict\n\n## Decisions made\n\nnone\n\n## Review notes\n\nnone\n"
}
EOF
  cat > .fixture/pr.txt <<'EOF'
feat(tui): show why a session is blocked (#12) #40
Draft . 12-show-blocked-reason into main
url: https://github.com/aphelion-labs/aphelion/pull/40

## Summary

spec proposal, awaiting approval

## Issue

Closes #12

## Spec change

- Change folder: `openspec/changes/12-show-blocked-reason/`
- Archived in this PR: no
EOF
}

# fixture_finish_ready: on 12-show-blocked-reason, the proposal for #12 and its
# implementation are committed and pushed, the tasks are still unticked, and
# draft pull request #40 exists.
fixture_finish_ready() {
  local c=openspec/changes/12-show-blocked-reason
  mkdir -p "$c/specs/tui"
  cat > "$c/.openspec.yaml" <<'EOF'
schema: spec-driven
created: 2026-10-15
goal: "Issue: #12"
EOF
  cat > "$c/README.md" <<'EOF'
# 12-show-blocked-reason

Show why a session is blocked
EOF
  cat > "$c/proposal.md" <<'EOF'
Issue: #12

## Why
Operators cannot tell an idle agent from one stuck on a permission prompt.

## What Changes
- Session status gains "blocked", shown with a reason.
- Blocked sessions are listed first.

## Capabilities

### Modified Capabilities
- `tui`: status gains "blocked" with a reason; blocked sessions sort first.

## Impact
- `internal/board`
EOF
  cat > "$c/tasks.md" <<'EOF'
## 1. Blocked status

- [ ] 1.1 Add the blocked status and its reason to Session; verified by TestBlockedShowsReason
- [ ] 1.2 Sort blocked sessions first; verified by TestBlockedFirst
EOF
  cat > "$c/specs/tui/spec.md" <<'EOF'
## MODIFIED Requirements

### Requirement: Show session status
The board SHALL show each session's status as busy, idle or blocked. A blocked session SHALL also show the reason it is blocked.

#### Scenario: Agent is working
- **WHEN** a session is executing a tool call
- **THEN** its row shows status "busy"

#### Scenario: Agent is waiting
- **WHEN** a session has no work in flight
- **THEN** its row shows status "idle"

#### Scenario: Agent is blocked
- **WHEN** a session is waiting on a permission prompt
- **THEN** its row shows status "blocked" and the reason "permission prompt"

## ADDED Requirements

### Requirement: Blocked sessions first
The board SHALL list blocked sessions above busy and idle sessions.

#### Scenario: Mixed states
- **WHEN** one blocked and one idle session are active
- **THEN** the blocked session is listed first
EOF
  fixture_git add -A
  fixture_git commit -q -m "docs: propose change for #12"

  cat > internal/board/board.go <<'EOF'
// Package board renders the session board (eval fixture).
package board

import "sort"

// Session is one agent session shown on the board.
type Session struct {
	Name   string
	Status string
	Reason string
}

// Render returns one line per session, blocked sessions first.
func Render(sessions []Session) string {
	sorted := append([]Session(nil), sessions...)
	sort.SliceStable(sorted, func(i, j int) bool {
		return sorted[i].Status == "blocked" && sorted[j].Status != "blocked"
	})
	out := ""
	for i, s := range sorted {
		if i > 0 {
			out += "\n"
		}
		out += s.Name + " " + s.Status
		if s.Status == "blocked" {
			out += " (" + s.Reason + ")"
		}
	}
	return out
}
EOF
  cat > internal/board/board_test.go <<'EOF'
package board

import "testing"

func TestBlockedShowsReason(t *testing.T) {
	got := Render([]Session{{Name: "a", Status: "blocked", Reason: "permission prompt"}})
	if got != "a blocked (permission prompt)" {
		t.Fatalf("got %q", got)
	}
}

func TestBlockedFirst(t *testing.T) {
	got := Render([]Session{{Name: "a", Status: "idle"}, {Name: "b", Status: "blocked", Reason: "permission prompt"}})
	if got != "b blocked (permission prompt)\na idle" {
		t.Fatalf("got %q", got)
	}
}
EOF
  fixture_git add -A
  fixture_git commit -q -m "feat(tui): show blocked reason"
  git push -q -u origin 12-show-blocked-reason
  fixture_open_pr
}

# fixture_warm_openspec: best effort. Fetches the pinned OpenSpec into the
# run's npm cache while the scaffold still has network access, so the agent's
# sandboxed npx call can find it. A failure here is not fatal; the agent's call
# may still reach the registry through the --allow-tools domain grant.
fixture_warm_openspec() {
  OPENSPEC_TELEMETRY=0 npx -y @fission-ai/openspec@1.14.2 --version > /dev/null 2>&1 || true
}
