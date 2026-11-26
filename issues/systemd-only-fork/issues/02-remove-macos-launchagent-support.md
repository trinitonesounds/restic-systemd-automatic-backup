---
id: 1663ca00-6259-4355-8f89-f585a28760af
title: "Remove macOS LaunchAgent support"
type: issue
status: ready-for-agent
blocked_by:
  - 01-remove-windows-scheduledtask-support.md
date: 2026-11-25
labels: []
---

**What to build:** The fork no longer installs, documents or accommodates macOS. The LaunchAgent plists and their install, activate and deactivate targets are gone, along with the Homebrew-only Makefile knobs (`LAUNCHAGENTDIR`, `SYSCONFDIR`) and the macOS log dir. The GNU vs BSD `install` switch is replaced by GNU flags only, and `resticw`'s digest check uses `sha256sum` only. The README has no macOS or Homebrew setup sections, no macOS notifier bullet and no macOS screenshot. The Linux desktop-notification instructions stay. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] No LaunchAgent sources, make targets or `launchctl` calls remain
- [ ] Makefile uses GNU `install` flags unconditionally; `SYSCONFDIR`/`LAUNCHAGENTDIR` removed and config still installs under `$PREFIX/etc/restic`
- [ ] `resticw` digest check uses `sha256sum` only and still runs (`resticw --help` works)
- [ ] README has no macOS/Homebrew setup, notes, notifier bullet or screenshot; the unused image is deleted
- [ ] `PREFIX=/tmp/restic-test make install-systemd` and `make uninstall` (same PREFIX) succeed; shellcheck passes
- [ ] `grep -ri 'macos\|launchagent\|launchctl\|homebrew\|brew '` (excluding CHANGELOG and .git) finds nothing

## Comments
