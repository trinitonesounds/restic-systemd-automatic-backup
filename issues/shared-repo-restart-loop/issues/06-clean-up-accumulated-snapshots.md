---
id: 269e3e53-92f6-4344-bbd7-1cd4d1a310e6
title: "Clean up the accumulated snapshots"
type: issue
status: ready-for-human
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
- [ ] Dry-run output was reviewed per host before the real forget
- [ ] One prune completed from the designated host
- [ ] Snapshot count per host is within retention limits; counts before and after are recorded under Comments
- [ ] `restic check` passes afterwards

## Comments
