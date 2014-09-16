pkgname = postgresql$(DISTSUFF)

SUBDIRS = . doc tests

bin_SCRIPTS = postgresql$(DISTSUFF)-setup

libexec_SCRIPTS = postgresql$(DISTSUFF)-ctl \
		  postgresql$(DISTSUFF)-check-db-dir

userunitsdir = /etc/systemd/system

systemdunitsdir = $(prefix)/lib/systemd/system
nodist_systemdunits_DATA = postgresql$(DISTSUFF).service postgresql$(DISTSUFF)@.service

nodist_pgdoc_DATA = README.rpm-dist

noinst_DATA = $(TEST_GEN_FILES_LIST)

postgresql$(DISTSUFF)-ctl: postgresql-ctl.in $(c_s)
	$(INSTANTIATE_SCRIPT)

postgresql$(DISTSUFF)-setup: postgresql-setup.in $(c_s)
	$(INSTANTIATE_SCRIPT)

postgresql$(DISTSUFF)-check-db-dir: postgresql-check-db-dir.in $(c_s)
	$(INSTANTIATE_SCRIPT)

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

README.rpm-dist: README.rpm-dist.in $(c_s)
	$(INSTANTIATE)

EXTRA_DIST = *.in

GENERATED_FILES = $(bin_SCRIPTS) \
		  $(libexec_SCRIPTS) \
		  $(nodist_pgdoc_DATA) \
		  $(pkgsysconf_DATA) \
		  $(nodist_systemdunits_DATA)

CLEANFILES = $(GENERATED_FILES) $(TEST_GEN_FILES_LIST)

$(TEST_GEN_FILES_LIST): $(GENERATED_FILES)
	$(AM_V_GEN)rm -rf $(TEST_GEN_FILES_LIST) && \
	for i in $(GENERATED_FILES); do \
	    echo $$i >> $@ ; \
	done

install-data-hook:
	test `id -u` -eq 0 && systemctl daemon-reload
