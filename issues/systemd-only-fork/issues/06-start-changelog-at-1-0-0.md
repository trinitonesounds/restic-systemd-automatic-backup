---
id: a42c72db-d406-4e94-9d4d-bdd5e33dcc19
title: "Start the CHANGELOG at 1.0.0"
type: issue
status: ready-for-agent
blocked_by:
  - 05-rebrand-readme-and-claude-md-as-fork.md
date: 2026-11-25
labels: []
---

**What to build:** The CHANGELOG reads as the fork's own history, starting at 1.0.0. That entry collects the current Unreleased items (TRACE debugging, warn on unset recommended vars), the fork's own changes since diverging (SFTP default repository, `--host`-scoped forget grouped by paths and tags, hourly retention, systemd retry and hardening, the restic cache dir, systemd-cat logging), and the removals (Windows, macOS, cron, GitHub CI). A note says that everything below is upstream's history. Upstream's entries through 7.4.0 stay under an "Upstream history" heading. Keep a Changelog format; no host-specific compare links. Tagging and pushing `v1.0.0` is left to the maintainer. See `docs/adr/0001-systemd-only-hard-fork.md` for the decision behind this.

## Acceptance criteria

- [ ] `## [1.0.0]` entry exists with Added/Changed/Removed sections covering the items above, plus an empty `[Unreleased]`
- [ ] Upstream entries (7.4.0 and earlier) are preserved verbatim under an "Upstream history" heading with a one-line note
- [ ] No compare/release links to the fork's own host

## Comments
