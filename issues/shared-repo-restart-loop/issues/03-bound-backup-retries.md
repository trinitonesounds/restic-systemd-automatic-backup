---
id: d380eff5-ef7c-4dbe-aec5-7948436047e9
title: "Make the retry limit actually limit retries"
type: issue
status: done
blocked_by:
  - 02-partial-snapshot-is-completed-backup.md
date: 2026-11-25
labels: []
---

**What to build:** A backup unit that keeps failing gives up after a small, known number of attempts and stays failed until the next timer run, instead of looping forever. The start-limit window must cover burst × (restart delay + the longest expected backup run), and the unit file's comment must state the real behaviour. The duplicate Description and nm-unmetered lines in the unit file are removed at the same time.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [x] With a backup that always fails (e.g. an unreachable repository), the unit makes at most the intended number of attempts and then stays failed (`systemctl show -p NRestarts` confirms)
- [x] The start-limit window and its comment explain the arithmetic (attempts, delay, assumed max runtime)
- [x] The next timer run still starts the unit normally after it hit the limit
- [x] `systemd-analyze verify` passes on the unit with no duplicate-key warnings
- [x] CHANGELOG Unreleased notes the change

## Comments

### 2026-11-27: done

- `StartLimitBurst=3`, `StartLimitIntervalSec=4h`. The window is 3 x (5 min RestartSec + up to 5 min random sleep in ExecStart + 60 min assumed longest run) = 210 min, rounded up. The unit comment spells out the arithmetic, that the 60 min is an assumption, that successful runs count (so the timer should fire at most every 80 min), how a timer behaves after the limit is hit, and `systemctl reset-failed` to retry sooner. `RestartSec` has a pointer back to it.
- Removed the duplicate `Description=` (kept the one already in effect, since the last value wins), the duplicate commented `nm-unmetered` line and a duplicate `ProtectControlGroups=`. `systemd-analyze verify` on the built unit shows only the unrelated `man restic(1)` doc lookup.
- Verified on systemd 259 with a user unit and the burst from the built unit, using a scaled window (15 s) and RestartSec (1 s):
  - A unit that always fails: 3 runs, then "Start request repeated too quickly", `NRestarts=3` (the refused restart is counted).
  - A manual start inside the window is refused, and one after the window runs.
  - With a timer firing every 6 s: triggers inside the window are refused, the timer stays active, and the first trigger after the window starts a fresh 3-attempt cycle with the restart counter reset.
- Not done: the 60 min longest run is not enforced. A `RuntimeMaxSec=` would guarantee it but could kill a legitimate long first backup or prune. Revisit once ticket 04 moves prune off the per-host backup. There is also no built-in max-restarts setting; an `ExecStartPre` check on `NRestarts` would remove the runtime dependence but was out of scope.
- Note for dev machines: `make install-*` to a scratch PREFIX fails here because this host's `install` is uutils and rejects `-B` (the Makefile's BSD branch). Pre-existing; the built unit under `build/` was tested instead.
