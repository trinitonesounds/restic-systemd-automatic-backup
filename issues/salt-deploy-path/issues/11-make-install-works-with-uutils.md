---
id: 67582e78-663f-47ee-a473-8655843c2384
title: "make install works with uutils coreutils"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** Installing config files and units with make works on hosts whose `install` is uutils coreutils, as well as GNU coreutils. Today the Makefile decides which backup-suffix flag to pass by grepping `install --version` for "GNU". uutils prints "uutils coreutils", so it gets the BSD `-B` flag, which uutils rejects. Every config and unit install then fails ("unexpected argument '-B'"). Installing scripts alone doesn't pass that flag, so it still works. Newer Ubuntu releases ship uutils as the default `install`, so fleet hosts will hit this when they upgrade.

uutils `install` accepts the GNU `--suffix=` form (checked with uutils 0.10.0: `install -b --suffix=.X.bak` keeps the old file as `.X.bak`). Since the fork is systemd/Linux only (ADR 0001), the BSD branch can probably go, and `--suffix` can be used everywhere; if macOS support is still in the tree when this lands, detect the BSD case explicitly instead of treating "not GNU" as BSD.

Context: found while testing shared-repo-restart-loop 03 on a dev machine with uutils coreutils 0.10.0. A scratch-PREFIX unit install failed there, so the built unit under `build/` was tested instead.

## Acceptance criteria

- [ ] A scratch-PREFIX install of scripts, config and units succeeds with uutils `install`
- [ ] The same install still succeeds with GNU `install` (e.g. `gnuinstall` on uutils systems, or a GNU host)
- [ ] An existing config file is still kept as a timestamped `.bak` copy under both
- [ ] CHANGELOG entry under [Unreleased]
