SUBDIRS = . doc

bin_SCRIPTS = postgresql$(DISTSUFF)-setup

libexec_SCRIPTS = postgresql$(DISTSUFF)-ctl

pkgsysconfdir = $(PKGCONFIG_DIR)
pkgsysconf_DATA = conf/postgresql$(DISTSUFF)

systemdunitsdir = $(prefix)/lib/systemd/system
systemdunits_DATA = postgresql$(DISTSUFF).service

nodist_pgdoc_DATA = README.rpm-dist

c_s_gen = $(AM_V_GEN)cmd="$(top_srcdir)/config.status --file=$@:$<" ; \
	if $(AM_V_P); then $$cmd; else $$cmd &>/dev/null; fi

c_s_script_gen = $(c_s_gen) && chmod +x $@

postgresql$(DISTSUFF)-ctl: postgresql-ctl.in
	$(c_s_script_gen)

postgresql$(DISTSUFF)-setup: postgresql-setup.in
	$(c_s_script_gen)

conf/postgresql$(DISTSUFF): conf/postgresql.in
	$(c_s_gen)

postgresql$(DISTSUFF).service: postgresql.service.in
	$(c_s_gen)

README.rpm-dist: README.rpm-dist.in
	$(c_s_gen)

EXTRA_DIST = *.in conf/*.in

CLEANFILES = $(bin_SCRIPTS) \
	     $(libexec_SCRIPTS) \
	     $(nodist_pgdoc_DATA) \
	     $(pkgsysconf_DATA) \
	     $(nodist_systemdunits_DATA)
