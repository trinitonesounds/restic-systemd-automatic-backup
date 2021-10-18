# Not file targets.
.PHONY: help install install-scripts install-conf install-systemd

### Macros ###
SRCS_SCRIPTS	= $(filter-out %cron_mail, $(wildcard usr/local/sbin/*))
SRCS_CONF	= $(filter-out %template, $(wildcard etc/restic/*))
SRCS_SYSTEMD	= $(wildcard etc/systemd/system/*)

# Just set PREFIX in envionment, like
# $ PREFIX=/tmp/test make
DEST_SCRIPTS	= $(PREFIX)/usr/local/sbin
DEST_CONF	= $(PREFIX)/etc/restic
DEST_SYSTEMD	= $(PREFIX)/etc/systemd/system


### Targets ###
# target: all - Default target.
all: install

# target: help - Display all targets.
help:
	@egrep "#\starget:" [Mm]akefile  | sed 's/\s-\s/\t\t\t/' | cut -d " " -f3- | sort -d

# target: install - Install all files
install: install-scripts install-conf install-systemd


# target: install-scripts - Install executables.
install-scripts:
	install -d $(DEST_SCRIPTS)
	install -m 0744 $(SRCS_SCRIPTS) $(DEST_SCRIPTS)

etc/restic/restic_env.sh:
	install -m 0600 etc/restic/restic_env.sh.template etc/restic/restic_env.sh

etc/restic/restic_pw.txt:
	install -m 0600 etc/restic/restic_pw.txt.template etc/restic/restic_pw.txt

# target: install-conf - Install restic configuration files.
# will create these files locally only if they don't already exist
install-conf: | etc/restic/restic_env.sh etc/restic/restic_pw.txt
	install -d $(DEST_CONF)
	install -m 0600 $(SRCS_CONF) $(DEST_CONF)

# target: install-systemd - Install systemd timer and service files
install-systemd:
	install -d $(DEST_SYSTEMD)
	install -m 0644 $(SRCS_SYSTEMD) $(DEST_SYSTEMD)
