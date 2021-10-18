# B2 and SFTP Respository and credentials.
# Extracted settings so both systemd timers and user can just source this for backups.
# See https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html

# SFTP Repository
# Be sure to define an SSH config Host for "restic-sftp"
export RESTIC_REPOSITORY="sftp:restic-sftp:/<repo-name>"
export RESTIC_PASSWORD_FILE="/etc/restic/restic_pw.txt"

# BackBlaze B2 Repository
#export RESTIC_REPOSITORY="b2:<b2-repo-name>"
#export B2_ACCOUNT_ID="<b2-account-id>"
#export B2_ACCOUNT_KEY="<b2-account-key>"
# How many network connections to set up to B2. Default is 5.
#B2_CONNECTIONS="b2.connections=50""


# Retention Prune settings
RETENTION_DAYS=14
RETENTION_WEEKS=8
RETENTION_MONTHS=12
RETENTION_YEARS=2

# What to backup
BACKUP_PATHS="/ /boot"

