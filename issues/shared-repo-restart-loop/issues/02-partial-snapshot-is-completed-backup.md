---
id: 1dafac4a-9e25-4966-b16c-0c3c6e953c72
title: "Treat a partial snapshot as a completed backup"
type: issue
status: ready-for-agent
blocked_by:
  - 01-no-empty-backup-target.md
date: 2026-11-25
labels: []
---

**What to build:** When restic saves a snapshot but some source files could not be read (exit 3), the backup run continues: it logs a clear warning, runs the retention `forget` step as normal, and then exits with status 3. The systemd backup unit never restarts on status 3, so a partial snapshot produces a visible failed unit (`OnFailure` email still fires) but no retry loop and no snapshot pile-up. Any other backup or forget failure keeps the current behaviour: the run stops, and the unit fails and retries.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [ ] A backup returning exit 3 still runs forget and the script ends with status 3
- [ ] The backup unit does not auto-restart on exit status 3, and still restarts on other non-zero statuses
- [ ] A backup returning any other non-zero status stops before forget, as today
- [ ] The warning in the journal says the snapshot was saved but incomplete
- [ ] Verified with a test repo and an unreadable file (e.g. `chmod 000`), running as a non-root user
- [ ] shellcheck passes; CHANGELOG Unreleased notes the behaviour change

## Comments
