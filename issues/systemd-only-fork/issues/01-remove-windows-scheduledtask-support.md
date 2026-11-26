---
id: b5a2a38c-590f-4a19-a183-dd6b6b06f76c
title: "Remove Windows ScheduledTask support"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-25
labels: []
---

**What to build:** The fork no longer installs, documents or special-cases Windows. Someone reading the repo finds no ScheduledTask scripts, no schedtask make targets, no Windows OS detection in the Makefile, and no Windows setup section (or its screenshot) in the README. The backup script always passes `--one-file-system` because there is no msys path left. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] No ScheduledTask sources, make targets, or OS detection (`CUR_OS`/`Windows_NT`) remain; `uninstall` no longer depends on a schedtask target
- [ ] `restic_backup.sh` has no `msys`/`OSTYPE` branch and always uses `--one-file-system`
- [ ] README has no Windows setup section, link, icon or screenshot; the unused image is deleted
- [ ] `PREFIX=/tmp/restic-test make install-systemd` and `make help` succeed; shellcheck passes on `bin/` scripts
- [ ] `grep -ri 'windows\|schedtask\|msys'` (excluding CHANGELOG and .git) finds nothing

## Comments
