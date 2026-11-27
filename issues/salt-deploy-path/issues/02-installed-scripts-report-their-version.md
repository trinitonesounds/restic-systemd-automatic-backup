---
id: f53144be-8408-4e1b-843b-ad6ec63d5663
title: "Installed scripts report the version they came from"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** The build stamps the release tag (or commit, when untagged) into each installed script. Every backup and check run logs that version at the start, and one command run on a host prints the installed version. Nobody has to compare md5 sums to know what a host is running.

## Acceptance criteria

- [ ] The installed backup and check scripts carry the version they were built from; the source tree keeps a placeholder, like the existing install-prefix substitution
- [ ] Each run's first journal line includes that version
- [ ] A documented one-liner prints the installed version on a host
- [ ] An install from a dirty tree is marked as such (e.g. a `-dirty` suffix)
- [ ] shellcheck clean; CHANGELOG entry

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
