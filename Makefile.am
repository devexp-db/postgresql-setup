SUBDIRS = . doc

bin_SCRIPTS = postgresql$(DISTSUFF)-setup

libexec_SCRIPTS = postgresql$(DISTSUFF)-ctl

config_status = $(top_srcdir)/config.status

postgresql$(DISTSUFF)-ctl: postgresql-ctl.in
	$(AM_V_GEN)cmd="$(config_status) --file=$@:$<" ; \
	if $(AM_V_P); then $$cmd; else $$cmd &>/dev/null; fi && chmod +x $@

postgresql$(DISTSUFF)-setup: postgresql-setup.in
	$(AM_V_GEN)cmd="$(config_status) --file=$@:$<" ; \
	if $(AM_V_P); then $$cmd; else $$cmd &>/dev/null; fi && chmod +x $@

CLEANFILES = $(bin_SCRIPTS) $(libexec_SCRIPTS)
