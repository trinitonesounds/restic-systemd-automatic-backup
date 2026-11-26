---
id: 633e4d42-2b70-4f5f-b855-2193788c0a4b
title: "Find and fix the unreadable file on ch-hvz-2"
type: issue
status: ready-for-human
blocked_by:
  - 01-no-empty-backup-target.md
date: 2026-11-25
labels: []
---

**What to build:** ch-hvz-2's nightly backup completes without "at least one source file could not be read". Find the file(s) restic reports as unreadable, either in the full journal for a recent run (the `error:` lines precede the warning) or by rerunning the backup with higher verbosity. Then fix the cause: exclude a volatile or irrelevant path, fix permissions, or account for the unit's sandboxing (e.g. `ProtectHome`, `PrivateDevices`).

HITL: needs access to the host and a decision on whether the file should be excluded or made readable.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [ ] The unreadable path(s) and the cause are recorded under Comments
- [ ] A manual `systemctl start restic-backup@default` on ch-hvz-2 exits 0
- [ ] Other hosts' journals are checked for the same warning and noted

## Comments

### 2026-11-25: no unreadable file; the empty backup target is the cause

- The ch-hvz-2 journal (48h) has no restic `error:` lines naming a file. Every run logs ` does not exist, skipping` (141×) and then `Warning: at least one source file could not be read` (132×).
- ch-hvz-2 runs restic **0.19.1**. Reproduced with a throwaway repo on that host: `restic backup <dir> ""` exits **3** with that exact warning, and without the empty target it exits 0. (restic 0.18.x exits 0 in the same case.)
- The empty target comes from `RESTIC_BACKUP_EXTRA_ARGS=` (empty in `_global.env.sh`): the xargs/printf conversion produces one empty-string argument. That is ticket 01.
- Fleet check (restic version | unit state | warnings in 48h | latest restart counter):
  - ch-salt3k-1: 0.19.1 | active | 273 | 4875
  - ch-haproxy-2: 0.19.1 | active | 276 | 1196
  - ch-git-2: 0.19.1 | activating | 277 | 841
  - ch-web-2: 0.19.1 | inactive | 265 | 2762
  - ch-web-3: 0.19.1 | inactive | 267 | 497
  - ch-mail-1: 0.18.0 | inactive | 0 | none (not affected)
  - Not checked: ch-mailtest-1 (publickey denied), ch-hvz-3 (host key verification failed), ch-haproxy-3 (connection closed). ch-nextcloud-2's /etc/restic was not readable without sudo.
- Status set to blocked on ticket 01. Remaining acceptance criterion: once ticket 01 is deployed, a manual run on ch-hvz-2 exits 0.


### 2026-11-25: unblocked

Ticket 01 is done (the fix is verified against restic 0.19.1). What remains for this ticket: deploy the fixed `restic_backup.sh` to ch-hvz-2 (and the other 0.19+/0.20 hosts), re-enable the timer, and confirm a manual run exits 0.
