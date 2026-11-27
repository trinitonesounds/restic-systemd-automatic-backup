---
id: 8f6eee96-d90b-4aa7-9dd3-6fed0c643c27
title: "Repo-host maintenance keeps the SFTP user's ownership"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** On a host that stores a repo locally and serves it to clients over SFTP, maintenance (check, repair, prune) runs as the user that owns the repo, not root. New index and pack files stay readable by every SFTP client. During the recovery, a `repair index` run as root on ch-harrison-1 left root-owned index files, and every client's backup failed with permission denied until they were chowned.

Related: shared-repo-restart-loop 04 (move pruning to one host). That host's prune would run through this.

## Acceptance criteria

- [ ] A supported way exists to run a profile's restic commands as a named user (e.g. a unit `User=` setting for that profile, or a wrapper option), documented in the README
- [ ] A scratch test shows files created by a maintenance run are owned by that user
- [ ] Running without it on a repo-host profile is warned against in the docs
- [ ] shellcheck clean; CHANGELOG entry

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
