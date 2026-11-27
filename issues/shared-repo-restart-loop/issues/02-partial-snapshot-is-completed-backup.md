---
id: 1dafac4a-9e25-4966-b16c-0c3c6e953c72
title: "Treat a partial snapshot as a completed backup"
type: issue
status: done
blocked_by:
  - 01-no-empty-backup-target.md
date: 2026-11-25
labels: []
---

**What to build:** When restic saves a snapshot but some source files could not be read (exit 3), the backup run continues: it logs a clear warning, runs the retention `forget` step as normal, and then exits with status 3. The systemd backup unit never restarts on status 3, so a partial snapshot produces a visible failed unit (`OnFailure` email still fires) but no retry loop and no snapshot pile-up. Any other backup or forget failure keeps the current behaviour: the run stops, and the unit fails and retries.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [x] A backup returning exit 3 still runs forget and the script ends with status 3
- [x] The backup unit does not auto-restart on exit status 3, and still restarts on other non-zero statuses
- [x] A backup returning any other non-zero status stops before forget, as today
- [x] The warning in the journal says the snapshot was saved but incomplete
- [x] Verified with a test repo and an unreadable file (e.g. `chmod 000`), running as a non-root user
- [x] shellcheck passes; CHANGELOG Unreleased notes the behaviour change

## Comments

### 2026-11-27: done

- `restic_backup.sh`: the backup's exit status is captured. Exit 3 logs `[WARN] Snapshot saved but incomplete…`, forget runs as usual, and the script exits 3 at the very end. Any other non-zero status exits immediately, before forget, as before.
- `restic-backup@.service`: `RestartPreventExitStatus=3`. The unit goes to failed (so `OnFailure=` fires where it is enabled) and does not restart. Other statuses still restart.
- Verified as non-root user with restic 0.20.0 and a throwaway repo: a `chmod 000` file → exit 3, forget ran, warning logged; all files readable → exit 0; missing exclude file → exit 1, forget did not run. The unit's `pipefail` + `systemd-cat` pipeline passes 3 through. A transient `systemd-run --user` unit with the same Restart settings showed `NRestarts=0` for exit 3 and kept restarting for exit 1.
- Not covered and left as is: if forget or the optional `RESTIC_NOTIFY_BACKUP_STATS` block fails after a partial backup, errexit exits with that status (not 3), so the unit restarts and backs up again. Bounded by the start limit. `OnFailure=` email was not tested end to end; it is commented out in the shipped unit.
- shellcheck is clean. The final exit is written as `[ … -eq 0 ] || exit …` because a bare top-level `exit` makes shellcheck 0.11 falsely report the trap handler as unused (SC2329).
