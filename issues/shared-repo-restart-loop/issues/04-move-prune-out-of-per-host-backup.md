---
id: b2c788f6-f430-4375-8977-8452f2111163
title: "Move pruning out of the per-host backup"
type: issue
status: done
blocked_by:
  - 02-partial-snapshot-is-completed-backup.md
date: 2026-11-25
labels: []
---

**What to build:** With many hosts backing up to one shared repo, each host's nightly run applies retention only to its own snapshots (`forget` scoped to its host, without pruning). Pruning, which needs an exclusive repo lock, runs as a separate prune service and timer that is enabled on just one designated host at a quiet time. Hosts' backups therefore never compete with a prune for the lock. The README documents the shared-repo setup: which host prunes, and how to enable the prune timer there. A single-host setup keeps working by enabling the prune timer on that host.

HITL: the maintainer chooses which host prunes and when, and confirms the default schedule.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [x] The per-host backup run no longer prunes; its forget remains scoped to the host and to the profile's tag
- [x] A prune service and timer exist and are installed by `make install-systemd`, but are not enabled by default
- [x] The prune unit uses the same retry and hardening approach as the backup unit and cannot loop forever
- [x] README explains the shared-repo layout and single-host enablement
- [ ] `PREFIX=/tmp/restic-test make install-systemd` installs the new units; `systemd-analyze verify` passes
- [x] CHANGELOG Unreleased notes the change, including that single-host users must enable the prune timer

## Comments

### 2026-11-27: done

Maintainer decisions: restic-01 is pruned from **ch-harrison-1** (the repo is local there), running as **cwh-backup** via a `User=` drop-in so repo files keep SFTP-readable ownership. Default schedule: **weekly, Sunday 05:00** (+ up to 10 min random delay, `Persistent=true`).

- `restic_backup.sh`: `forget` no longer has `--prune`; still scoped to `--host` and the profile's tag. Added `--retry-lock 30m`: verified that `forget` needs an exclusive lock (it failed while another backup held the repo, and with `--retry-lock` it waited and succeeded).
- New `restic_prune.sh` (unlock stale locks, then `restic prune --retry-lock 30m`, background + wait like the others) and `restic-prune@.service` / `.timer`. Same retry limit (3 attempts, 4 h window, arithmetic in the comment) and hardening as the backup unit. The cache uses `CacheDirectory=restic-prune` so a `User=` drop-in works without a root-owned cache.
- Installed by default (not in the Makefile filter-out) and enabled nowhere.
- README: setup step to enable the prune timer (single host: on that host; shared repo: on one host), and a "Shared repository across hosts" section covering the prune host, the `User=` drop-in, env/password file readability, `RESTIC_CACHE_DIR` and `ProtectHome` caveats, and the restic 0.16+ requirement for `--retry-lock`. CLAUDE.md updated.
- Tested with restic 0.20.0 and a throwaway repo: backups with keep-hourly 1 forget one snapshot and print nothing about prune. The shipped prune unit, run in a user systemd manager, pruned the leftover data (dry-run prune afterwards: 0 blobs). For that test, `Requires=local-fs.target` and the capability-dropping hardening lines were stripped, since a non-root user manager can't apply them; the hardening is the same set the backup unit already runs with in production. `systemd-analyze verify` on the built prune service and timer is clean. shellcheck clean.
- Not tested: `make install-systemd` to a scratch PREFIX (this dev box's uutils `install` rejects `-B`, see salt-deploy-path 11; the Makefile glob picks up the new files), and the `User=` drop-in in system mode.
- Cron, LaunchAgent and ScheduledTask setups get no prune job and now never prune; noted in the CHANGELOG, since the fork is removing them (systemd-only-fork 01–03).

Rollout notes for restic-01 (for the maintainer):
- Deploy the new script and units fleet-wide **before or together with** enabling prune on ch-harrison-1. Until a host has the new script, it still runs `forget --prune` itself.
- On ch-harrison-1: the test-restic01 profile, the files it sources and its password file must be readable by cwh-backup. Add the `User=cwh-backup` drop-in, then `systemctl enable --now restic-prune@test-restic01.timer`. The repo is under `/mnt`, so no `ReadWritePaths` is needed.
- ch-harrison-1's prune must run restic 0.16+ (`--retry-lock`). The unit's default PATH finds the Salt-managed 0.20.0 in `/usr/local/sbin` before the old 0.13.1 in `/usr/local/bin`; salt-deploy-path 09 removes the old one.
- This partly covers salt-deploy-path 10 (repo-host maintenance keeps ownership) for prune.
