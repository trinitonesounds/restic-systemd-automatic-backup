---
id: 6de5cea4-c43c-4ec8-beec-dd8fa6921811
title: "Stop passing an empty backup target when no extra args are set"
type: issue
status: done
blocked_by: []
date: 2026-11-25
labels: [simple]
---

**What to build:** When a profile leaves `RESTIC_BACKUP_EXTRA_ARGS` empty, the backup no longer passes an empty-string argument to restic, so the log stops showing ` does not exist, skipping` for a phantom path. Non-empty extra args keep their current quoting behaviour, including arguments that contain spaces (upstream #111).

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min. This ticket is cleanup found during that diagnosis. On restic 0.18.1 the empty target alone does not cause exit 3.

## Acceptance criteria

- [x] With empty `RESTIC_BACKUP_EXTRA_ARGS`, the backup command receives no empty-string argument and no "does not exist, skipping" line appears
- [x] Extra args containing quoted values with spaces still arrive as single arguments
- [x] shellcheck passes

## Comments

### 2026-11-25: this is the root cause on restic 0.19

Ticket 05's investigation corrected the "does not cause exit 3" note above: on restic **0.19.1** an empty-string target makes `restic backup` exit 3 ("at least one source file could not be read"). Every 0.19.1 host in the fleet is in the restart loop because of it. Do this ticket first; it is the fix for the incident.

### 2026-11-25: resolved

- Extra args are parsed with `xargs -r`, so an empty or whitespace-only `RESTIC_BACKUP_EXTRA_ARGS` gives no arguments. Quoted values with spaces still arrive as one argument.
- Two more ways to pass an empty-string argument, both fixed: `B2_ARG` is now an empty array when `B2_CONNECTIONS` is unset (before, it was one `""`, passed to backup and forget), and empty `RESTIC_BACKUP_PATHS` entries (`/a::/b`) are dropped.
- Review follow-ups: quoted `$HOSTNAME` in forget, removed the unused `extra_args` array. shellcheck is now clean.
- Verified with a stub `restic` that logs its arguments, in 5 cases: empty, whitespace-only, quoted with a space, B2 set, and an empty path entry. HEAD fails 3 checks; the fix passes all 9.
- Verified with real restic 0.19.1 on ch-hvz-2 against a throwaway repo in /tmp: HEAD exits 3 and skips forget; the fix exits 0, saves one snapshot and runs forget.
- Not deployed to any host yet.
