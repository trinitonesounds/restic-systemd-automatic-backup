---
id: 1968dec2-ebda-4c7d-91ac-e63748c2b05d
title: "Restore Salt's access to this repo"
type: issue
status: ready-for-human
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** Salt can fetch this repo again. First, retry `git.latest` on a canary host. It failed during the rollout because GitHub rejected the deploy key, so a fresh deploy key on GitHub is probably the quick fix; if `git.latest` works, keep it for now. If it still fails, the scope grows: move the repo to GitLab and fetch with a deploy access token. That ties into cutting the upstream ties (systemd-only-fork 07) and the "GitLab later" decision in ADR 0001.

HITL: needs access to the Salt master, GitHub/GitLab settings, and a decision if the GitLab path is taken.

## Acceptance criteria

- [ ] `git.latest` for this repo succeeds on a canary host
- [ ] The way it was restored (fresh key, or GitLab plus token) and where the credential lives are recorded under Comments
- [ ] If the GitLab path is taken, the decision is recorded (ADR update or new ADR)

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
