---
id: be99516a-3de7-418a-ad07-4b74ee94cd39
title: "Salt sets the notification address"
type: issue
status: ready-for-human
blocked_by:
  - 01-failure-email-on-by-default.md
date: 2026-11-27
labels: []
---

**What to build:** The Salt pillar sets the failure email recipient in the profile env file Salt already manages, so every host emails the real address. This only adds a value to a file Salt already writes, so it does not wait on the pinned-release deploy work (salt-deploy-path 07).

HITL: the change is in the Salt repo, and the canary test needs a deliberately broken backup.

Context: failure email exists in the repo but is off by default. `OnFailure=` is commented out in both units, the email unit has a placeholder recipient written into it, and the Makefile leaves the email files out of a default install. Turning it on meant editing shipped files, and the real address could not go into this public repo. Every fleet host runs postfix, and Salt already manages the profile env files. Since shared-repo-restart-loop 02, a partial snapshot (exit 3) fails the unit at once without restarting, so it notifies immediately; other failures notify once the restarts run out.

## Acceptance criteria

- [ ] The pillar sets the recipient (per role, overridable per host); the address lives only in the Salt repo
- [ ] After deploy, every host's env file has the recipient set
- [ ] A deliberately failing backup on a canary host delivers exactly one email to that address
- [ ] The host's units and scripts are on the release from ticket 01 before the canary test
