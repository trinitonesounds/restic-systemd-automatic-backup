---
id: 1c56d9bc-8272-4906-be3d-5558a689bde8
title: "make test runs a first bats test of the backup script"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** `make test` runs shellcheck and a bats suite. The suite puts a stub `restic` first on PATH that records every argument it receives and returns a chosen exit code. The first tests lock in the no-empty-argument behaviour from shared-repo-restart-loop 01: no empty-string argument reaches restic when the extra args are empty or only whitespace, or when the path list has empty entries, and quoted extra args keep their spaces.

## Acceptance criteria

- [ ] `make test` runs shellcheck and the bats suite, and fails if either fails
- [ ] Without bats installed, `make test` stops with a clear message saying how to get it
- [ ] Whether bats is a system package or pinned in the repo is decided and recorded under Comments
- [ ] A reusable stub restic records arguments and its exit code is set per test
- [ ] Tests cover empty, whitespace-only and quoted extra args, and empty path entries
- [ ] CLAUDE.md's validation section describes `make test` instead of "no test suite"

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
