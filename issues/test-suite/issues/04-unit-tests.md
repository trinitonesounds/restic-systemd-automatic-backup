---
id: 0b6e82b4-f603-4212-99ff-d72e82e42848
title: "Unit tests"
type: issue
status: ready-for-agent
blocked_by: 
  - 01-make-test-with-first-bats-test.md
date: 2026-11-27
labels: []
---

**What to build:** Tests for the systemd units as built (placeholders substituted). `systemd-analyze verify` passes on each unit. A transient user unit with the shipped backup unit's restart settings confirms that exit 3 does not restart and exit 1 does. Tests that need a user systemd session are skipped with a stated reason when none is available.

## Acceptance criteria

- [ ] Every shipped unit passes `systemd-analyze verify` (ignoring known-harmless warnings, listed in the test)
- [ ] Restart behaviour is read from the shipped unit, not copied into the test, so changing the unit changes what is tested
- [ ] Exit 3: no restart; exit 1: restarts
- [ ] Skipped with a reason when no user systemd session exists

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
