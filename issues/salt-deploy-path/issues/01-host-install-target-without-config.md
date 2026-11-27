---
id: e9ded004-54d5-49ab-b5aa-8d77c07eb3f7
title: "Host install target that never touches the profile config"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** One make target installs the scripts and the systemd units, and nothing under the profile config directory. It is the documented way to install on a host whose profiles, password files and global env are managed by Salt. Today the only full-install target also installs the config files, so it would overwrite Salt-managed files, including the password file, and it can't be used on fleet hosts.

## Acceptance criteria

- [ ] A make target installs scripts and units only; a dry run shows no config-directory paths
- [ ] A trial install to a scratch PREFIX with pre-existing config files leaves them byte-identical and creates no `.bak` copies
- [ ] README and CLAUDE.md name this target as the install path for config-managed hosts
- [ ] CHANGELOG entry under [Unreleased]

Context: during the 2026-11 restic-01 restart-loop recovery, the fixed backup script had to be deployed by hand. The Salt checkout could not fetch, hosts were updated by `git pull` plus a manual scripts-only make, and installed versions were checked by comparing md5 sums. That rollout also turned up drifted units and stale restic binaries.
