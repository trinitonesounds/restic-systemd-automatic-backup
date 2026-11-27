---
id: 0989e3ac-645c-4e9e-8646-37ec706db7e8
title: "Each run logs which restic it used"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** The backup and check scripts log the path and version of the restic binary at the start of every run. A profile can name an explicit restic binary, so the unit's PATH order can't silently pick an older copy. On ch-mail-1 and ch-harrison-1 the units ran restic 0.18.0 and 0.13.1 while `restic version` in an interactive shell showed 0.20.0.

## Acceptance criteria

- [ ] Each backup/check run logs the resolved restic path and `restic version` before doing any work
- [ ] An optional profile variable selects the restic binary; unset keeps today's PATH lookup
- [ ] An unusable configured binary fails the run with a clear message
- [ ] The variable is documented in the global env file; shellcheck clean; CHANGELOG entry

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
