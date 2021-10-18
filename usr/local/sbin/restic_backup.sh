#!/usr/bin/env bash
# Make a backup of my system with restic.
# This script is typically run by: /etc/systemd/system/restic-backup.{service,timer}

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

# How many backups to keep.
RETENTION_DAYS=14
RETENTION_WEEKS=16
RETENTION_MONTHS=18
RETENTION_YEARS=3

# What to backup, and what to not
BACKUP_PATHS="/ /boot /home"
[ -d /mnt/media ] && BACKUP_PATHS+=" /mnt/media"
BACKUP_EXCLUDES="--exclude-file /etc/restic/backup_exclude"
for dir in /home/*
do
    if [ -f "$dir/.backup_exclude" ]
    then
        BACKUP_EXCLUDES+=" --exclude-file $dir/.backup_exclude"
    fi
done

BACKUP_TAG=systemd.timer


# Set all environment variables like
# B2_ACCOUNT_ID, B2_ACCOUNT_KEY, SFTP Service RESTIC_REPOSITORY etc.
source /etc/restic/restic_env.sh

# NOTE start all commands in background and wait for them to finish.
# Reason: bash ignores any signals while child process is executing and thus my trap exit hook is not triggered.
# However if put in subprocesses, wait(1) waits until the process finishes OR signal is received.
# Reference: https://unix.stackexchange.com/questions/146756/forward-sigterm-to-child-in-bash

# Remove locks from other stale processes to keep the automated backup running.
restic unlock &
wait $!

# Special options
declare -A RESTIC_OPTIONS
for opt in B2_CONNECTIONS OTHER
do
    if [[ ${!opt:-notset} = "notset" ]]; then
        RESTIC_OPTIONS+=""
    else
        RESTIC_OPTIONS+="--option ${!opt} "
    fi
done


# Do the backup!
# See restic-backup(1) or http://restic.readthedocs.io/en/latest/040_backup.html
# --one-file-system makes sure we only backup exactly those mounted file systems specified in $BACKUP_PATHS, and thus not directories like /dev, /sys etc.
# --tag lets us reference these backups later when doing restic-forget.
restic backup \
    --verbose \
    --one-file-system \
    --tag $BACKUP_TAG \
    "${RESTIC_OPTIONS[*]}"  \
    $BACKUP_EXCLUDES \
    $BACKUP_PATHS &
wait $!

# Dereference and delete/prune old backups.
# See restic-forget(1) or http://restic.readthedocs.io/en/latest/060_forget.html
# --group-by only the tag and path, and not by hostname. This is if you create a repo per host, and if the hostname accidentially change some time, there would now be multiple backup sets.
    #--group-by "paths,tags" \
restic forget \
    --verbose \
    --tag $BACKUP_TAG \
    "${RESTIC_OPTIONS[*]}"  \
    --prune \
    --keep-daily $RETENTION_DAYS \
    --keep-weekly $RETENTION_WEEKS \
    --keep-monthly $RETENTION_MONTHS \
    --keep-yearly $RETENTION_YEARS &
wait $!

# Check repository for errors.
# NOTE this takes much time (and data transfer from remote repo?), do this in a separate systemd.timer which is run less often.
#restic check &
#wait $!

echo "Backup & cleaning is done."
