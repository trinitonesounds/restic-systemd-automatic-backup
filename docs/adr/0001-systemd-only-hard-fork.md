---
status: accepted
---

# Hard fork from upstream, systemd only

This repo began as a fork of [erikw/restic-automatic-backup-scheduler](https://github.com/erikw/restic-automatic-backup-scheduler) and selectively merged upstream changes. Every host it backs up runs systemd, and the fork's own work (retry limits, unit hardening, `/var/cache/restic`, `systemd-cat` logging, per-host timers) was systemd-specific anyway. So we hard-forked: we stop merging upstream and support **systemd only**. The macOS LaunchAgent, Windows ScheduledTask and cron schedulers are removed, along with their scripts, Makefile targets and docs. Upstream fixes worth having are ported by hand. Versioning restarts at **1.0.0**, and upstream's changelog (through 7.4.0) is kept below it as history. The Makefile keeps its `$INSTALL_PREFIX` substitution so that `PREFIX=/tmp/... make install-systemd` dry runs and any future packaging still work. Only the cross-OS logic is removed.

## Considered Options

- **Soft fork, keep merging upstream**: rejected. Every upstream merge would conflict on the deleted files, and upstream has been quiet since 7.4.0 (2023).
- **Any Linux (keep cron)**: rejected. Cron already lagged behind the systemd features, and its main reason to exist was FreeBSD.
- **Continue upstream semver at 8.0.0**: rejected in favour of a clean 1.0.0 that marks the fork as its own project.
- **Hardcode FHS paths in the Makefile**: rejected, because it loses dry-run installs and packaging flexibility.

## Consequences

- The README is rebranded as a fork that credits upstream. Homebrew and AUR install paths, upstream badges and the packaging release steps are removed.
- The GitHub workflows (`linter.yml`, `stale.yml`) are deleted. Linting is done locally with `shellcheck` until the repo moves to GitLab, where pipelines will be added then.
- Docs and the CHANGELOG don't link to the fork's own host, so the planned GitLab move needs no link fixes.
- `make uninstall` no longer knows about cron files. No existing host uses cron, so no migration step is needed.
