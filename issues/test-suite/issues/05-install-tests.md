---
id: 39dd742b-2be8-4f15-9a65-6aaad5944ace
title: "Install tests"
type: issue
status: ready-for-agent
blocked_by: 
  - 01-make-test-with-first-bats-test.md
date: 2026-11-27
labels: []
---

**What to build:** Tests that install into a scratch PREFIX and check the result: every install-prefix placeholder was replaced, optional files are left out of a default install, and existing config files are backed up as documented. When salt-deploy-path 01 (config-safe host install) and failure-notification 01 (email installed by default) land, their behaviour gets tests here too.

## Acceptance criteria

- [ ] No installed file still contains the install-prefix placeholder
- [ ] Optional files are absent from a default install
- [ ] A pre-existing config file is backed up, not silently overwritten
- [ ] Runs entirely under a temp directory; never touches the real system

Context: the repo has no test suite; validation has been shellcheck plus trial installs to a scratch PREFIX. During the 2026-11 restic-01 restart-loop work, the empty-argument fix and the partial-snapshot handling were verified by hand with a stub restic, a throwaway repo and transient user units. These tickets turn those checks into a repeatable suite. CI was dropped (ADR 0001), so the suite runs locally; a pipeline can follow the move to GitLab.
