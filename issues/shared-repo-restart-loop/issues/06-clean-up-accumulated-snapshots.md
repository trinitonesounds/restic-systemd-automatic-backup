---
id: 269e3e53-92f6-4344-bbd7-1cd4d1a310e6
title: "Clean up the accumulated snapshots"
type: issue
status: claimed
blocked_by:
  - 03-bound-backup-retries.md
  - 04-move-prune-out-of-per-host-backup.md
date: 2026-11-25
labels: []
---

**What to build:** After the fixes are deployed to every host, the shared repo goes back to holding only the snapshots the retention policy allows. For each host: preview its retention forget with a dry run and review what it would remove, then run it for real. Then run one prune from the designated prune host. Snapshot counts per host should match the retention settings.

HITL: this deletes snapshots from the production repo and needs the maintainer to review each dry run.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [ ] Every host runs the fixed scripts and units
- [x] Dry-run output was reviewed per host before the real forget
- [x] One prune completed from the designated host
- [x] Snapshot count per host is within retention limits; counts before and after are recorded under Comments
- [x] `restic check` passes afterwards

## Comments

### 2026-11-25/26: forget done; prune exposed repo damage

- Dry runs and real forgets were done on ch-harrison-1, where restic-01 is local (`/etc/restic/test-restic01.env.sh`, restic 0.20.0), using each host's own tag, host and retention (1h/14d/8w/12m/2y). Every forget exited 0; before/after snapshot counts:
  - ch-hvz-2: 8,603 → 29
  - ch-salt3k-1 (tag `ch-salt3k`): 12,456 → 30
  - ch-haproxy-2: 4,061 → 30
  - ch-git-2: 5,111 → 30
  - ch-web-2: 5,170 → 30
  - ch-web-3: 4,269 → 30
  - Total: 39,491 snapshots forgotten. The loop began in Aug 2026 on ch-salt3k-1 and Sep–Oct on the others (when they moved to restic 0.19).
- `restic prune` failed: `failed finding blobs: id 8973ddb9… not found in repository`. Nothing was deleted; the repo is still 179G.
- `restic check`: 20,400 trees missing. `repair snapshots --dry-run` (count corrected later; the first parse counted every snapshot listed): **247 of 456** snapshots are damaged. Every live host's damaged snapshots are from 2026-05-02 or earlier (ch-git-2: 2026-08-15), and every snapshot of the retired hosts is damaged. So the packs were lost around May 2026, before this restart loop. Identical directories (e.g. `/etc`, Salt-deployed `.vim_runtime`) are shared trees, so losing one damages every snapshot that contains it.
- `restic repair index` recovered nothing (still 20,400 missing): the pack files are gone from disk. There are no btrfs snapshots of `/mnt/btrfs_raid/backups/restic-01` and no offsite copy (the `cwh-backup` rsync user is left over from BackupPC). The maintainer accepted the data loss.
- Likely cause, not proven: a prune around May 2026 deleted packs that other hosts' snapshots still referenced. Every host runs `forget --prune` on the shared repo. Ticket 04 (single prune host) is the prevention.
- `repair index` was run as root, which left 46 new index files owned `root:root` 440. The SFTP user `cwh-backup` could not read them, so every host's backup failed with `permission denied`. Fixed with `chown cwh-backup:cwh-backup`. **Any restic write on ch-harrison-1 must be followed by restoring `cwh-backup` ownership.**
- Fresh `backup --force` (no forget or prune) on the 7 live hosts: all exited 0, and all 7 new snapshots are clean.
- Next: `repair snapshots --forget` (rewrites the 247 damaged snapshots with empty dirs where data is lost), restore ownership, `check`, then one prune.

### 2026-11-26: repo repaired and pruned

- `repair snapshots --forget` (on ch-harrison-1, exit 0): **modified 247** damaged snapshots and **removed 77** that became empty (all their data was lost). 379 snapshots remain. Ownership restored to `cwh-backup` (0 files owned by anyone else), and `check` found no errors.
- One `prune` from ch-harrison-1 (exit 0): 121.9 GiB removed, 46.7 GiB repacked, 131,938 old packs deleted. The repo went from **180G to 58G**. Ownership restored again, and `check` found no errors.
- The ch-hvz-2 verification run (ticket 05) then backed up, forgot and pruned cleanly through the normal unit.
- Blockers 03 and 04 were waived by the maintainer so the repo could be recovered now.
- Remaining: roll the fixed `restic_backup.sh` (md5 `41c51106…`) out to the other hosts and re-enable their timers one host at a time. ch-mail-1 and ch-harrison-1 run custom or older scripts and binaries, so diff them first. Until ticket 04 lands, every host still runs `forget --prune` on the shared repo.
