setup		= $(NAME_BINARYBASE)-setup
setup_in	= postgresql-setup.in

ctl		= $(NAME_BINARYBASE)-ctl
ctl_in		= postgresql-ctl.in

checkdb		= $(NAME_BINARYBASE)-check-db-dir
checkdb_in	= postgresql-check-db-dir.in

service		= $(NAME_SERVICE).service
service_in	= postgresql.service.in
serviceat	= $(NAME_SERVICE)@.service
serviceat_in	= postgresql.service.in

initscript	= $(NAME_SERVICE)
initscript_in	= postgresql.init.in

EXTRA_DIST =
GENERATED_FILES =
CLEANFILES =

# include $(srcdir)/build-helpers/Makefile.inc

SUBDIRS = . doc tests

bin_SCRIPTS = $(setup)
libexec_SCRIPTS = $(ctl) $(checkdb)

legacyscriptsdir = $(systemdlegacyscriptsdir)/$(NAME_SERVICE)

# TODO: Ideally, 'make distcheck' should check every file we generate.
if WANT_SYSVINIT
initscripts_DATA = $(initscript)
else
systemdunits_DATA = $(service) $(serviceat)
legacyscripts_SCRIPTS = initdb upgrade
endif

pgdoc_DATA = $(README_DIST_BASENAME)

noinst_DATA = $(TEST_GEN_FILES_LIST)

$(ctl): $(ctl_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(setup): $(setup_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(checkdb): $(check) $(checkdb_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(initscript): $(initscript_in) $(c_s)
	$(INSTANTIATE)

initdb upgrade: legacy-sysv-script.in $(c_s)
	$(INSTANTIATE_SCRIPT)

# In ideal world, postgresql@.service would be hardlink to postgresql.service.
# That would require, however, the rhbz#1141824 resolved so we could install
# system-default drop-in file.  Make a "almost" duplicate files now.

$(serviceat): $(serviceat_in) $(c_s)
	$(AM_V_GEN)$(SED_CALL) \
	    -e '/@PGDATA_ENVIRONMENT[@]/d' \
	    $< > $@

$(service): $(service_in) $(c_s)
	$(AM_V_GEN)$(SED_CALL) \
	    -e 's|@PGDATA_ENVIRONMENT[@]|Environment=PGDATA=$(PGDATADIR)|' \
	    $< > $@

$(README_DIST_BASENAME): $(README_DIST_BASENAME).in $(c_s)
	$(INSTANTIATE)

EXTRA_DIST += \
	$(srcdir)/*.in \
	$(srcdir)/etc/postgresql-setup/upgrade/postgresql.conf

include $(srcdir)/share/postgresql-setup/Makefile.inc

GENERATED_FILES += \
	$(bin_SCRIPTS) \
	$(libexec_SCRIPTS) \
	$(pgdoc_DATA) \
	$(pkgsysconf_DATA) \
	$(systemdunits_DATA) \
	$(initscripts_DATA) \
	$(legacyscripts_SCRIPTS)

CLEANFILES += $(GENERATED_FILES) $(TEST_GEN_FILES_LIST)

$(TEST_GEN_FILES_LIST): $(GENERATED_FILES)
	$(AM_V_GEN)rm -rf $(TEST_GEN_FILES_LIST) && \
	for i in $(GENERATED_FILES); do \
	    echo $$i >> $@ ; \
	done

install-data-hook:
	test `id -u` -ne 0 || systemctl daemon-reload
	$(MKDIR_P) $(DESTDIR)/$(sysconfdir)/$(NAME_BINARYBASE)-setup/upgrade

GL_GEN_BIN = gitlog-to-changelog
GL_GEN = if test -d .git; then \
	   $(SHELL) $(top_srcdir)/$(config_aux_dir)/missing --run \
	   $(GL_GEN_BIN) --format='%s%n%n%b%n' --since 2014-06-30 > ChangeLog ; \
	   rc=$$? ; \
	   if test $$rc -eq 127; then \
	     if test x"$$IGNORE_CHANGELOG" != xyes; then \
	       echo >&2 "ERROR: Get the $(GL_GEN_BIN) or ignore ChangeLog by IGNORE_CHANGELOG=yes" ; \
	       exit 1 ; \
	     fi ; \
	   else \
	     test $$rc -eq 0 ; \
	   fi \
	 fi

.PHONY: ChangeLog
ChangeLog:
	$(AM_V_GEN)$(GL_GEN)

dist-hook: ChangeLog

DISTCLEANFILES = ChangeLog
