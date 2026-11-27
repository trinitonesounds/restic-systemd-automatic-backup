---
id: c01735a9-8fcc-4b31-9baf-1b1c05a3d55b
title: "Real-restic integration tests"
type: issue
status: ready-for-agent
blocked_by: 
  - 01-make-test-with-first-bats-test.md
date: 2026-11-27
labels: []
---

**What to build:** A few tests run the real backup script with real restic against a throwaway local repo: a normal backup followed by forget, and an unreadable file (`chmod 000`) that gives exit 3 with forget still run. These tests are skipped with a stated reason when restic is not installed or when running as root, since root can read the unreadable file.

## Acceptance criteria

- [ ] Each test creates and removes its own repo; no shared state between tests
- [ ] Normal backup: exit 0, one snapshot saved, forget ran
- [ ] Unreadable file: exit 3, warning logged, forget ran
- [ ] Skipped with a reason when restic is missing or the user is root

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
