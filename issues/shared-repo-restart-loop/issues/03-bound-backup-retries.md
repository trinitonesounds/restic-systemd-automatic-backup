---
id: d380eff5-ef7c-4dbe-aec5-7948436047e9
title: "Make the retry limit actually limit retries"
type: issue
status: ready-for-agent
blocked_by:
  - 02-partial-snapshot-is-completed-backup.md
date: 2026-11-25
labels: []
---

**What to build:** A backup unit that keeps failing gives up after a small, known number of attempts and stays failed until the next timer run, instead of looping forever. The start-limit window must cover burst × (restart delay + the longest expected backup run), and the unit file's comment must state the real behaviour. The duplicate Description and nm-unmetered lines in the unit file are removed at the same time.

Context: on 2026-11-25 several hosts sharing one restic repo looped for hours (restart counter 112 on ch-hvz-2) and each built up hundreds of snapshots. restic exited 3 ("snapshot saved" but "at least one source file could not be read"). errexit made the script stop before forget, `Restart=on-failure` re-ran it every 5 min, and the start limit (4 starts in 1260s) never triggered because each cycle takes about 9.5 min.

## Acceptance criteria

- [ ] With a backup that always fails (e.g. an unreachable repository), the unit makes at most the intended number of attempts and then stays failed (`systemctl show -p NRestarts` confirms)
- [ ] The start-limit window and its comment explain the arithmetic (attempts, delay, assumed max runtime)
- [ ] The next timer run still starts the unit normally after it hit the limit
- [ ] `systemd-analyze verify` passes on the unit with no duplicate-key warnings
- [ ] CHANGELOG Unreleased notes the change

## Comments
