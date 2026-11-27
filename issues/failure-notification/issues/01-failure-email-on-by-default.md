---
id: 966ca86c-e55c-491e-9499-1bc1c11ec1cc
title: "Failure email on by default, with the address from host config"
type: issue
status: ready-for-agent
blocked_by: []
date: 2026-11-27
labels: []
---

**What to build:** A failed backup or check run sends an email through the host's local MTA, with no edits to shipped files. The backup and check units ship with `OnFailure=` enabled, and the email script and unit install by default. The recipient is read from a variable in the profile env files, which Salt manages. When the variable is unset, mail goes to `root`, which the MTA delivers through the host's aliases. No real address ever goes into the repo. The subject says whether the run produced a partial snapshot (exit 3) or failed.

Context: failure email exists in the repo but is off by default. `OnFailure=` is commented out in both units, the email unit has a placeholder recipient written into it, and the Makefile leaves the email files out of a default install. Turning it on meant editing shipped files, and the real address could not go into this public repo. Every fleet host runs postfix, and Salt already manages the profile env files. Since shared-repo-restart-loop 02, a partial snapshot (exit 3) fails the unit at once without restarting, so it notifies immediately; other failures notify once the restarts run out.

## Acceptance criteria

- [ ] Units ship with `OnFailure=` enabled for both backup and check; a default install includes the email script and unit
- [ ] Recipient comes from a documented env variable (in the global env file, empty by default); unset or empty sends to `root`
- [ ] No real email address appears anywhere in the repo
- [ ] Subject distinguishes a partial snapshot (exit 3) from a failure
- [ ] The Gmail-era send throttle is either dropped or kept with its state outside `/tmp`; the choice is noted under Comments
- [ ] Verified on a scratch install with a stub `sendmail`: exit 3, exit 1, and unset recipient each produce the expected message
- [ ] README's email section is updated to describe the new default; shellcheck clean; CHANGELOG entry
