SUBDIRS = . doc

bin_SCRIPTS = postgresql$(DISTSUFF)-setup

libexec_SCRIPTS = postgresql$(DISTSUFF)-ctl \
		  postgresql$(DISTSUFF)-check-db-dir

pkgsysconfdir = $(PKGCONFIG_DIR)
pkgsysconf_DATA = conf/postgresql$(DISTSUFF)

systemdunitsdir = $(prefix)/lib/systemd/system
nodist_systemdunits_DATA = postgresql$(DISTSUFF).service

nodist_pgdoc_DATA = README.rpm-dist

# Encouraged by autoconf documentation itself.  When we use config.status
# directly, e.g. libexecdir may result into '${exec_prefix}/libexec' -- but we
# need fully expanded strings there.
edit = $(SED) \
	-e 's|@DISTSUFF[@]|$(DISTSUFF)|g' \
	-e 's|@libdir[@]|$(libdir)|g' \
	-e 's|@libexecdir[@]|$(libexecdir)|g' \
	-e 's|@PG_CTL_BIN[@]|$(PG_CTL_BIN)|g' \
	-e 's|@PGDATADIR[@]|$(PGDATADIR)|g' \
	-e 's|@pgdocdir[@]|$(pgdocdir)|g' \
	-e 's|@PGENGINE[@]|$(PGENGINE)|g' \
	-e 's|@PGMAJORVERSION[@]|$(PGMAJORVERSION)|g' \
	-e 's|@PGVERSION[@]|$(PGVERSION)|g' \
	-e 's|@PKGCONFIG_DIR[@]|$(PKGCONFIG_DIR)|g' \
	-e 's|@POSTGRES_HOMEDIR[@]|$(POSTGRES_HOMEDIR)|g' \
	-e 's|@PREVMAJORVERSION[@]|$(PREVMAJORVERSION)|g' \
	-e 's|@PREVPGENGINE[@]|$(PREVPGENGINE)|g' \
	-e 's|@README_DIST[@]|$(README_DIST)|g' \
	-e 's|@SU[@]|$(SU)|g' \
	-e 's|@VERSION[@]|$(VERSION)|g' \
	$< > $@

c_s = $(top_srcdir)/config.status

c_s_gen = $(AM_V_GEN)$(edit)

c_s_script_gen = $(c_s_gen) && chmod +x $@

postgresql$(DISTSUFF)-ctl: postgresql-ctl.in $(c_s)
	$(c_s_script_gen)

postgresql$(DISTSUFF)-setup: postgresql-setup.in $(c_s)
	$(c_s_script_gen)

postgresql$(DISTSUFF)-check-db-dir: postgresql-check-db-dir.in $(c_s)
	$(c_s_script_gen)

conf/postgresql$(DISTSUFF): conf/postgresql.in $(c_s)
	$(c_s_gen)

postgresql$(DISTSUFF).service: postgresql.service.in $(c_s)
	$(c_s_gen)

README.rpm-dist: README.rpm-dist.in $(c_s)
	$(c_s_gen)

EXTRA_DIST = *.in conf/*.in

CLEANFILES = $(bin_SCRIPTS) \
	     $(libexec_SCRIPTS) \
	     $(nodist_pgdoc_DATA) \
	     $(pkgsysconf_DATA) \
	     $(nodist_systemdunits_DATA)

install-exec-hook:
	rm -rf $(DESTDIR)$(systemdunitsdir)/postgresql$(DISTSUFF)@.service
	ln $(DESTDIR)$(systemdunitsdir)/postgresql$(DISTSUFF).service \
	   $(DESTDIR)$(systemdunitsdir)/postgresql$(DISTSUFF)@.service
