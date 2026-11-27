---
id: 56ae2a3d-764e-4065-9fb9-89550f25e4db
title: "Salt deploys a pinned release and verifies it"
type: issue
status: ready-for-human
blocked_by:
  - 01-host-install-target-without-config.md
  - 02-installed-scripts-report-their-version.md
  - 06-restore-salt-access-to-repo.md
date: 2026-11-27
labels: []
---

**What to build:** The Salt pillar names a release tag, not `master`. When the checkout changes, Salt runs the host install target, and the state fails if the installed version stamp doesn't match the pin. A push to master no longer deploys anything; a rollout is a pillar change, and it can go to a canary host first.

HITL: the change is in the Salt repo, and the first rollout needs approval.

## Acceptance criteria

- [ ] The pillar sets the release per role (overridable per host, for a canary)
- [ ] A checkout change triggers the host install target; an unchanged checkout triggers nothing
- [ ] The state fails when the installed version doesn't match the pin
- [ ] Rolled out to a canary host first, then the fleet; every host reports the pinned version

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
