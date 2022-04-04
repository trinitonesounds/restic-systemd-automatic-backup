#!/usr/bin/env bash
# Check  for errors in the repository with "restic check".
# This script is typically run by: /etc/systemd/system/restic-check.{service,timer}

# Exit on failure, pipe failure
set -e -o pipefail

# Clean up lock if we are killed.
# If killed by systemd, like $(systemctl stop restic), then it kills the whole cgroup and all it's subprocesses.
# However if we kill this script ourselves, we need this trap that kills all subprocesses manually.
exit_hook() {
    echo "In exit_hook(), being killed" >&2
    jobs -p | xargs kill
    restic unlock
}
trap exit_hook INT TERM


source /etc/restic/restic_env.sh

# Special options
declare -A RESTIC_OPTIONS
for opt in B2_CONNECTIONS OTHER
do
    if [[ ${!opt:-notset} = "notset" ]]; then
        RESTIC_OPTIONS+=
    else
        RESTIC_OPTIONS+="--option ${!opt} "
    fi
done

# Remove locks from other stale processes to keep the automated backup running.
# NOTE nope, don't unlock like restic_backup.sh. restic_backup.sh should take precedence over this script.
#restic unlock &
#wait $!

# Check repository for errors.
restic check \
        ${RESTIC_OPTIONS[*]}  \
        --verbose &
wait $!
