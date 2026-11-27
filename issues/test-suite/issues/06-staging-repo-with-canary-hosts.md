---
id: a474b5b0-1920-4a7f-a67d-9e83a64ed292
title: "Staging repo with canary hosts"
type: issue
status: ready-for-human
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** A separate restic repo next to restic-01, served the same way (SFTP as the repo-owning user), with 2–3 canary hosts backing up to it on the real units and timers. New releases and new restic versions run there for an agreed period before the fleet gets them. This catches what local tests cannot: real timing, several hosts sharing one repo, pruning contention, file ownership on the repo host, and which restic binary the unit actually runs.

HITL: needs a repo, SFTP access, canary host choices and a promotion rule.

## Acceptance criteria

- [ ] The staging repo exists, isolated from restic-01, with its own password
- [ ] 2–3 canary hosts back up to it on schedule using the real units
- [ ] A runbook is recorded: which hosts, how a release is promoted, and what to check (exit status, restarts, snapshot counts, repo file ownership, restic version in use)
- [ ] One release goes through the promotion flow end to end

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
