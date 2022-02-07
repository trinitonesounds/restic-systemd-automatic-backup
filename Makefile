#### Notes ####################################################################
# This build process is done in three stages (out-of-source build):
# 1. copy source files to the local build directory.
# 2. build dir: replace the string "$INSTALL_PREFIX" with the value of $PREFIX
# 3. install files from the build directory to the target directory.
#
# Why this dance?
# * To fully support that a user can install this project to a custom path e.g.
#   $(PREFIX=/usr/local make install), we need to modify the files that refer
#   to other files on disk. We do this by having a placeholder
#   "$INSTALL_PREFIX"  that is substituted with the value of $PREFIX when
#   installed.
# * We don't want to modify the files that are controlled by git, thus let's
#   copy them to a build directory and then modify.

#### Non-file targets #########################################################
.PHONY: help clean uninstall \
	install-systemd install-cron \
	install-targets-script install-targets-conf install-targets-systemd \
	install-targets-cron

#### Macros ###################################################################
NOW := $(shell date +%Y-%m-%d_%H:%M:%S)

# GNU and macOS install have incompatible command line arguments.
GNU_INSTALL := $(shell install --version 2>/dev/null | \
			   grep -q GNU && echo true || echo false)
ifeq ($(GNU_INSTALL),true)
    BAK_SUFFIX = --suffix=.$(NOW).bak
else
    BAK_SUFFIX = -B .$(NOW).bak
endif

# Create parent directories of a file, if not existing.
# Reference: https://stackoverflow.com/a/25574592/265508
MKDIR_PARENTS=sh -c '\
	     dir=$$(dirname $$1); \
	     test -d $$dir || mkdir -p $$dir \
	     ' MKDIR_PARENTS

# Source directories.
DIR_SCRIPT		= bin
DIR_CONF		= etc/restic
DIR_SYSTEMD		= usr/lib/systemd/system
DIR_CRON		= etc/cron.d
DIR_LAUNCHAGENT	= Library/LaunchAgents

# Source files.
SRCS_SCRIPT		= $(filter-out %cron_mail, $(wildcard $(DIR_SCRIPT)/*))
SRCS_CONF		= $(wildcard $(DIR_CONF)/*)
SRCS_SYSTEMD	= $(wildcard $(DIR_SYSTEMD)/*)
SRCS_CRON		= $(wildcard $(DIR_CRON)/*)
SRCS_LAUNCHAGENT= $(wildcard $(DIR_LAUNCHAGENT)/*)

# Local build directory. Sources will be copied here,
# modified and then installed from this directory.
BUILD_DIR				:= build
BUILD_DIR_SCRIPT		= $(BUILD_DIR)/$(DIR_SCRIPT)
BUILD_DIR_CONF			= $(BUILD_DIR)/$(DIR_CONF)
BUILD_DIR_SYSTEMD		= $(BUILD_DIR)/$(DIR_SYSTEMD)
BUILD_DIR_CRON			= $(BUILD_DIR)/$(DIR_CRON)
BUILD_DIR_LAUNCHAGENT	= $(BUILD_DIR)/$(DIR_LAUNCHAGENT)

# Sources copied to build directory.
BUILD_SRCS_SCRIPT		= $(addprefix $(BUILD_DIR)/, $(SRCS_SCRIPT))
BUILD_SRCS_CONF			= $(addprefix $(BUILD_DIR)/, $(SRCS_CONF))
BUILD_SRCS_SYSTEMD		= $(addprefix $(BUILD_DIR)/, $(SRCS_SYSTEMD))
BUILD_SRCS_CRON			= $(addprefix $(BUILD_DIR)/, $(SRCS_CRON))
BUILD_SRCS_LAUNCHAGENT	= $(addprefix $(BUILD_DIR)/, $(SRCS_LAUNCHAGENT))

# Destination directories
DEST_DIR_SCRIPT		= $(PREFIX)/$(DIR_SCRIPT)
DEST_DIR_CONF		= $(PREFIX)/$(DIR_CONF)
DEST_DIR_SYSTEMD	= $(PREFIX)/$(DIR_SYSTEMD)
DEST_DIR_CRON		= $(PREFIX)/$(DIR_CRON)
DEST_DIR_LAUNCHAGENT= $(HOME)/$(DIR_LAUNCHAGENT)

# Destination file targets.
DEST_TARGS_SCRIPT		= $(addprefix $(PREFIX)/, $(SRCS_SCRIPT))
DEST_TARGS_CONF			= $(addprefix $(PREFIX)/, $(SRCS_CONF))
DEST_TARGS_SYSTEMD		= $(addprefix $(PREFIX)/, $(SRCS_SYSTEMD))
DEST_TARGS_CRON			= $(addprefix $(PREFIX)/, $(SRCS_CRON))
DEST_TARGS_LAUNCHAGENT	= $(addprefix $(HOME)/, $(SRCS_LAUNCHAGENT))

INSTALLED_FILES = $(DEST_TARGS_SCRIPT) $(DEST_TARGS_CONF) \
				  $(DEST_TARGS_SYSTEMD) $(DEST_TARGS_CRON) \
				  $(DEST_TARGS_LAUNCHAGENT)


#### Targets ##################################################################
# target: help - Default target; displays all targets.
help:
	@egrep "#\starget:" [Mm]akefile | cut -d " " -f3- | sort -d

# target: clean - Remove build files.
clean:
	$(RM) -r $(BUILD_DIR)

# target: uninstall - Uninstall ALL files from all install targets.
uninstall:
	@for file in $(INSTALLED_FILES); do \
			echo $(RM) $$file; \
			$(RM) $$file; \
	done

# To change the installation root path,
# set the PREFIX variable in your shell's environment, like:
# $ PREFIX=/usr/local make install-systemd
# $ PREFIX=/tmp/test make install-systemd
# target: install-systemd - Install systemd setup.
install-systemd: install-targets-script install-targets-conf \
					install-targets-systemd

# target: install-cron - Install cron setup.
install-cron: install-targets-script install-targets-conf install-targets-cron

# target: install-launchagent - Install LaunchAgent setup.
install-launchagent: install-targets-script install-targets-conf \
						install-targets-launchagent

# Install targets. Prereq build sources as well,
# so that build dir is re-created if deleted.
install-targets-script: $(DEST_TARGS_SCRIPT) $(BUILD_SRCS_SCRIPT)
install-targets-conf: $(DEST_TARGS_CONF) $(BUILD_SRCS_CONF)
install-targets-systemd: $(DEST_TARGS_SYSTEMD) $(BUILD_SRCS_SYSTEMD)
install-targets-cron: $(DEST_TARGS_CRON) $(BUILD_SRCS_CRON)
install-targets-launchagent: $(DEST_TARGS_LAUNCHAGENT) $(BUILD_SRCS_LAUNCHAGENT)

# Copies sources to build directory & replace "$INSTALL_PREFIX".
$(BUILD_DIR)/% : %
	@${MKDIR_PARENTS} $@
	cp $< $@
	sed -i.bak -e 's|$$INSTALL_PREFIX|$(PREFIX)|g' $@; rm $@.bak

# Install destination script files.
$(DEST_DIR_SCRIPT)/%: $(BUILD_DIR_SCRIPT)/%
	@${MKDIR_PARENTS} $@
	install -m 0755 $< $@

# Install destination conf files. Additionally backup existing files.
$(DEST_DIR_CONF)/%: $(BUILD_DIR_CONF)/%
	@${MKDIR_PARENTS} $@
	install -m 0600 -b $(BAK_SUFFIX) $< $@

# Install destination systemd files.
$(DEST_DIR_SYSTEMD)/%: $(BUILD_DIR_SYSTEMD)/%
	@${MKDIR_PARENTS} $@
	install -m 0644 $< $@

# Install destination cron files.
$(DEST_DIR_CRON)/%: $(BUILD_DIR_CRON)/%
	@${MKDIR_PARENTS} $@
	install -m 0644 $< $@

# Install destination launchagent files.
$(DEST_DIR_LAUNCHAGENT)/%: $(BUILD_DIR_LAUNCHAGENT)/%
	${MKDIR_PARENTS} $@
	install -m 0444 $< $@
