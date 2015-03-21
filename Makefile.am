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

initscript	= initscript
initscript_in	= postgresql.init.in

readme_dist	= README.rpm-dist
readme_dist_db	= README.rpm-dist.sgml
readme_dist_m4	= README.rpm-dist.m4
readme_dist_sed	= README.rpm-dist.sed
readme_template	= README.rpm-dist.template

EXTRA_DIST =
INTERMEDIATE_FILES =
GENERATED_FILES =
CLEANFILES =

# include $(srcdir)/build-helpers/Makefile.inc

SUBDIRS = . doc tests

bin_SCRIPTS = $(setup)
libexec_SCRIPTS = $(ctl) $(checkdb)

legacyscriptsdir = $(systemdlegacyscriptsdir)/$(NAME_SERVICE)

noinst_DATA =

# TODO: Ideally, 'make distcheck' should check every file we generate.
if WANT_SYSVINIT
noinst_DATA += $(initscript)
GENERATED_FILES += $(initscript)
else
systemdunits_DATA = $(service) $(serviceat)
legacyscripts_SCRIPTS = initdb upgrade
endif

pgdoc_DATA = $(readme_dist)

noinst_DATA += $(TEST_GEN_FILES_LIST)

$(ctl): $(ctl_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(setup): $(setup_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(checkdb): $(check) $(checkdb_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

$(initscript): $(initscript_in) $(c_s)
	$(INSTANTIATE_SCRIPT)

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

$(readme_dist_sed): $(readme_template) $(c_s)
	$(INSTANTIATE)

$(readme_dist_m4): $(readme_dist_sed)
	$(INSTANTIATE_CONV) && \
	    m4 -P < $< > $@

$(readme_dist_db): $(readme_dist_m4)
	$(INSTANTIATE_CONV) && \
	    $(SED_CALL) < $(readme_dist_m4) | m4 -P > $(readme_dist_db)

$(readme_dist): $(readme_dist_db) $(srcdir)/style.dsl
	$(INSTANTIATE_CONV) && docbook2txt -d $(srcdir)/style.dsl $(readme_dist_db) >/dev/null && \
	    mv -f $(readme_dist).txt $(readme_dist)

EXTRA_DIST += \
	$(srcdir)/*.in \
	$(srcdir)/etc/postgresql-setup/upgrade/postgresql.conf \
	$(readme_template) \
	style.dsl

include $(srcdir)/share/postgresql-setup/Makefile.inc

GENERATED_FILES += \
	$(bin_SCRIPTS) \
	$(libexec_SCRIPTS) \
	$(pgdoc_DATA) \
	$(pkgsysconf_DATA) \
	$(systemdunits_DATA) \
	$(legacyscripts_SCRIPTS)

INTERMEDIATE_FILES += \
	$(readme_dist_m4) \
	$(readme_dist_sed) \
	$(readme_dist_db)

CLEANFILES += $(GENERATED_FILES) $(TEST_GEN_FILES_LIST) $(INTERMEDIATE_FILES)

$(TEST_GEN_FILES_LIST): $(GENERATED_FILES)
	$(AM_V_GEN)rm -rf $(TEST_GEN_FILES_LIST) && \
	for i in $(GENERATED_FILES); do \
	    echo $$i >> $@ ; \
	done

install-data-hook:
if WANT_SYSVINIT
else
	test `id -u` -ne 0 || systemctl daemon-reload
endif
	$(MKDIR_P) $(DESTDIR)/$(sysconfdir)/$(NAME_BINARYBASE)-setup/upgrade

install-exec-hook:
if WANT_SYSVINIT
	$(MKDIR_P) $(DESTDIR)/$(initscriptsdir)
	$(install_sh_SCRIPT) $(initscript) $(DESTDIR)/$(initscriptsdir)/$(NAME_SERVICE)
endif

uninstall-hook:
	rm -rf $(DESTDIR)/$(initscriptsdir)/$(NAME_SERVICE)

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
