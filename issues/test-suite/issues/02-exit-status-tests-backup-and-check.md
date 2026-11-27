---
id: 04b7d66c-8cb9-4085-baae-a8bf5721477e
title: "Exit-status tests for the backup and check scripts"
type: issue
status: ready-for-agent
blocked_by: 
  - 01-make-test-with-first-bats-test.md
date: 2026-11-27
labels: []
---

**What to build:** Tests that lock in how the backup and check scripts react to restic's exit status, using the stub. Backup: exit 0 runs forget and exits 0; exit 3 (partial snapshot) runs forget, logs the incomplete-snapshot warning and exits 3; any other status stops before forget and exits with that status. Missing required env vars fail fast. The check script gets the same treatment for its own success and failure paths.

## Acceptance criteria

- [ ] Backup: tests for exit 0, 3 and a non-3 failure, asserting whether forget ran and the final exit status
- [ ] Backup: a missing required env var fails before any restic call
- [ ] Check script: success and failure statuses pass through
- [ ] All tests run without a real restic or network

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
