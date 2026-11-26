---
id: 633e4d42-2b70-4f5f-b855-2193788c0a4b
title: "Find and fix the unreadable file on ch-hvz-2"
type: issue
status: ready-for-human
blocked_by: []
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
