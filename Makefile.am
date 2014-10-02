pkgname = postgresql$(DISTSUFF)

SUBDIRS = . doc tests

bin_SCRIPTS = postgresql$(DISTSUFF)-setup

libexec_SCRIPTS = postgresql$(DISTSUFF)-ctl \
		  postgresql$(DISTSUFF)-check-db-dir

userunitsdir = /etc/systemd/system

if WANT_SYSVINIT
initscriptsdir = $(prefix)/etc/init.d
nodist_initscripts_DATA = postgresql$(DISTSUFF).init
else
systemdunitsdir = $(prefix)/lib/systemd/system
nodist_systemdunits_DATA = postgresql$(DISTSUFF).service postgresql$(DISTSUFF)@.service
endif

nodist_doc_DATA = $(README_DIST_BASENAME)

noinst_DATA = $(TEST_GEN_FILES_LIST)

postgresql$(DISTSUFF)-ctl: postgresql-ctl.in $(c_s)
	$(INSTANTIATE_SCRIPT)

postgresql$(DISTSUFF)-setup: postgresql-setup.in $(c_s)
	$(INSTANTIATE_SCRIPT)

postgresql$(DISTSUFF)-check-db-dir: postgresql-check-db-dir.in $(c_s)
	$(INSTANTIATE_SCRIPT)

postgresql$(DISTSUFF).init: postgresql.init.in $(c_s)
	$(INSTANTIATE)

# In ideal world, postgresql@.service would be hardlink to postgresql.service.
# That would require, however, the rhbz#1141824 resolved so we could install
# system-default drop-in file.  Make a "almost" duplicate files now.

postgresql$(DISTSUFF)@.service: postgresql.service.in $(c_s)
	$(AM_V_GEN)$(SED_CALL) \
	    -e '/@PGDATA_ENVIRONMENT[@]/d' \
	    $< > $@

postgresql$(DISTSUFF).service: postgresql.service.in $(c_s)
	$(AM_V_GEN)$(SED_CALL) \
	    -e 's|@PGDATA_ENVIRONMENT[@]|Environment=PGDATA=$(PGDATADIR)|' \
	    $< > $@

$(README_DIST_BASENAME): $(README_DIST_BASENAME).in $(c_s)
	$(INSTANTIATE)

EXTRA_DIST = $(srcdir)/*.in

GENERATED_FILES = $(bin_SCRIPTS) \
		  $(libexec_SCRIPTS) \
		  $(nodist_doc_DATA) \
		  $(pkgsysconf_DATA) \
		  $(nodist_systemdunits_DATA) \
		  $(nodist_initscripts_DATA)

CLEANFILES = $(GENERATED_FILES) $(TEST_GEN_FILES_LIST)

$(TEST_GEN_FILES_LIST): $(GENERATED_FILES)
	$(AM_V_GEN)rm -rf $(TEST_GEN_FILES_LIST) && \
	for i in $(GENERATED_FILES); do \
	    echo $$i >> $@ ; \
	done

install-data-hook:
	test `id -u` -ne 0 || systemctl daemon-reload

GL_GEN_BIN = gitlog-to-changelog
GL_GEN = $(SHELL) $(top_srcdir)/$(config_aux_dir)/missing --run \
	 $(GL_GEN_BIN) --format='%s%n%n%b%n' --since 2013-01-01 > ChangeLog ; \
	 rc=$$? ; \
	 if test $$rc -eq 127; then \
	   if test x"$$IGNORE_CHANGELOG" != xyes; then \
	     echo >&2 "ERROR: Get the $(GL_GEN_BIN) or ignore ChangeLog by IGNORE_CHANGELOG=yes" ; \
	     exit 1 ; \
	   fi ; \
	 else \
	   test $$rc -eq 0 ; \
	 fi

.PHONY: ChangeLog
ChangeLog:
	$(AM_V_GEN)$(GL_GEN)

dist-hook: ChangeLog

DISTCLEANFILES = ChangeLog
