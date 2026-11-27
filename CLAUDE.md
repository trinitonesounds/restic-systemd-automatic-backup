# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Bash scripts plus OS scheduler definitions that run `restic` backups on a timer: systemd (primary), cron, macOS LaunchAgent, and Windows ScheduledTask. This repo is a personal fork (`origin` = trinitonesounds) of `upstream` = erikw/restic-automatic-backup-scheduler. Local `master` carries fork-specific changes. The `upstream-master` branch tracks upstream `main`. Upstream changes are merged in selectively ("pull relevant upstream changes"), so expect merge-conflict cleanup in `CHANGELOG.md`, `README.md` and env files.

Fork differences from upstream worth knowing before editing:
- The default repository is SFTP (`sftp:restic-sftp:/<repo-name>`, which needs an SSH config `Host restic-sftp`), not B2. The B2 variables remain as fallbacks.
- `restic forget` in `bin/restic_backup.sh` adds `--host $HOSTNAME`, `--group-by "paths,tags"` and `--retry-lock`, keeps hourly snapshots (`RESTIC_RETENTION_HOURS`), and does not prune. Pruning is a separate `restic-prune@` unit, enabled on one host per shared repository.
- `restic-backup@.service` uses `StartLimit*` plus `Restart=on-failure` for retries, systemd security hardening (`ProtectSystem`, `ReadWritePaths=/var/cache/restic`, …), and `RESTIC_CACHE_DIR=/var/cache/restic`. `make install-systemd` creates that cache dir.

## Commands

There is no test suite. Validation is:
- **Lint:** CI runs super-linter with `VALIDATE_BASH` (shellcheck) on `bin/**` and `*.sh`. Run it locally with `shellcheck bin/restic_backup.sh bin/restic_check.sh etc/restic/*.env.sh`.
- **Trial install to a scratch prefix** (never touch the real system while developing):
  `PREFIX=/tmp/restic-test make install-systemd` (also `install-cron`, `install-launchagent`, `install-schedtask`)
- `make help` lists the targets. `make clean` removes `build/`. `sudo make uninstall` removes everything installed, including configs.
- **Debug a script:** `TRACE=1 restic_backup.sh` turns on `set -x`.
- **Run a backup manually:** `source /etc/restic/<profile>.env.sh && restic_backup.sh`, or for systemd, `systemctl start restic-backup@<profile>`.

## Architecture

**Install pipeline (Makefile).** Sources mirror their install paths (`bin/`, `etc/restic/`, `usr/lib/systemd/system/`, `etc/cron.d/`, `Library/LaunchAgents/`). `make` copies each file into `build/<same path>`, replaces the literal string `{{ INSTALL_PREFIX }}` with `$(INSTALL_PREFIX)` (which defaults to `$PREFIX`), then `install`s into `$PREFIX/<path>`. So:
- Any source file that references another installed file must use the literal `{{ INSTALL_PREFIX }}` placeholder, never a hardcoded `/etc/...` or `/bin/...` path.
- `build/` is gitignored output. Edit the source tree, not `build/`.
- Config installs (`etc/restic/*`) back up existing files with a timestamped `.bak` suffix (GNU vs BSD `install` flags are handled).
- `SRCS_SCRIPT`/`SRCS_SYSTEMD` use `filter-out` to exclude optional files (`cron_mail`, `systemd-email`, `nm-unmetered-connection.*`, `status-email-user@.service`). New optional files must be added there too, or they get installed by default.

**Profiles = env files.** All runtime configuration is environment variables. `etc/restic/<profile>.env.sh` sources `_global.env.sh` first, then overrides it. Each scheduler selects a profile by name:
- systemd: template units `restic-backup@<profile>` and `restic-check@<profile>`. `ExecStart` sources `{{ INSTALL_PREFIX }}/etc/restic/%I.env.sh` and then runs the script, piped to `systemd-cat`.
- cron, LaunchAgent and ScheduledTask hardcode the `default` profile.
- `bin/resticw --profile X <restic args>` sources a profile and runs plain `restic` commands.

**Scripts.** `bin/restic_backup.sh` runs `restic unlock`, `backup`, then `forget` (scoped to its host and tag, no prune). `bin/restic_prune.sh` runs `restic prune` from `restic-prune@<profile>.timer`, which is installed but enabled on only one host per repository. `bin/restic_check.sh` runs `restic check`. Both `assert_envvars` the required variables and warn about missing recommended ones. Every restic call is started in the background and followed by `wait $!`, so the `INT`/`TERM` trap can kill children and `restic unlock`. Keep that pattern for any new restic call. Other behavior: path lists in `RESTIC_BACKUP_PATHS` are colon-separated; a per-path `<path>/.backup_exclude.txt` is picked up automatically; an executable `etc/restic/pre_backup.sh` runs before each backup if it exists; `--one-file-system` is skipped on Windows (`msys`).

**`bin/resticw`** has a docopt.sh-generated parser that is hash-checked against the `DOC` string. If you change `DOC`, regenerate it with `docopt.sh bin/resticw`. The README's path for this (`usr/local/bin/resticw`) is outdated.

## Conventions

- `.editorconfig`: tabs (width 4), LF line endings, final newline.
- Record user-visible changes in `CHANGELOG.md` under `[Unreleased]` (Keep a Changelog format). Releases are `vX.Y.Z` tags. The AUR and Homebrew packaging belongs to upstream.

## Agent skills

### Issue tracker

Issues are tracked locally as markdown files under `issues/<feature>/`. Per-repo config: `docs/agents/issue-tracker.md`; it points at the authoritative contract seed.

### Triage labels

Canonical triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) plus local lifecycle statuses (`claimed`, `blocked`, `done`), no overrides. Per-repo config: `docs/agents/triage-labels.md`; vocabulary is the `setup-skills` `triage-labels.md` contract.

### Domain docs

Single-context. Consumer rules: the `setup-skills` `domain.md` contract. This repo's own domain docs: `GLOSSARY.md` and `docs/adr/` (created lazily by `/domain-modeling`).
