#!/usr/bin/env bash
# Prune the repository: remove data no snapshot references any more.
# Backups only run `restic forget` for their own host and tag. Pruning needs an
# exclusive repository lock, so with several hosts sharing one repository it
# runs on exactly one host, from restic-prune@<profile>.timer.
# See restic_backup.sh on how this script is run (it's analogous for this script).

set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE-0}" =~ ^1|t|y|true|yes$ ]] && set -o xtrace

# Clean up lock if we are killed.
# If killed by systemd, like $(systemctl stop restic), then it kills the whole cgroup and all it's subprocesses.
# However if we kill this script ourselves, we need this trap that kills all subprocesses manually.
exit_hook() {
	echo "In exit_hook(), being killed" >&2
	jobs -p | xargs kill
	restic unlock
}
trap exit_hook INT TERM

# Assert that all needed environment variables are set.
assert_envvars() {
	local varnames=("$@")
	for varname in "${varnames[@]}"; do
		if [ -z ${!varname+x} ]; then
			printf "%s must be set for this script to work.\n\nDid you forget to source a {{ INSTALL_PREFIX }}/etc/restic/*.env.sh profile in the current shell before executing this script?\n" "$varname" >&2
			exit 1
		fi
	done
}

assert_envvars RESTIC_REPOSITORY RESTIC_VERBOSITY_LEVEL

B2_ARG=( )
[ -z "${B2_CONNECTIONS+x}" ] || B2_ARG=(--option b2.connections="$B2_CONNECTIONS")

# NOTE start all commands in background and wait for them to finish, so the
# trap above can run. See restic_backup.sh.

# Remove stale locks (only those whose process is gone), like restic_backup.sh.
restic unlock "${B2_ARG[@]}" &
wait $!

# Prune needs an exclusive lock: wait for running backups (and their forget)
# to finish instead of failing.
restic prune \
	--verbose="$RESTIC_VERBOSITY_LEVEL" \
	--retry-lock 30m \
	"${B2_ARG[@]}" &
wait $!

echo "Prune is done."
