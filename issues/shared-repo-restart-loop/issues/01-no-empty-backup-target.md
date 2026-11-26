---
id: 6de5cea4-c43c-4ec8-beec-dd8fa6921811
title: "Stop passing an empty backup target when no extra args are set"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-25
labels: [simple]
---

**What to build:** When a profile leaves `RESTIC_BACKUP_EXTRA_ARGS` empty, the backup no longer passes an empty-string argument to restic, so the log stops showing ` does not exist, skipping` for a phantom path. Non-empty extra args keep their current quoting behaviour, including arguments that contain spaces (upstream #111).

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min. This ticket is cleanup found during that diagnosis. On restic 0.18.1 the empty target alone does not cause exit 3.

## Acceptance criteria

- [ ] With empty `RESTIC_BACKUP_EXTRA_ARGS`, the backup command receives no empty-string argument and no "does not exist, skipping" line appears
- [ ] Extra args containing quoted values with spaces still arrive as single arguments
- [ ] shellcheck passes

## Comments
