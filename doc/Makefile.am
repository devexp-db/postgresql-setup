HELP2MAN = $(SHELL) $(top_srcdir)/$(config_aux_dir)/missing --run help2man

man_MANS = $(srcdir)/postgresql$(DISTSUFF)-setup.1

# TODO: distribute also help2man

$(srcdir)/postgresql$(DISTSUFF)-setup.1: $(top_srcdir)/postgresql-setup.in
	$(AM_V_GEN)$(HELP2MAN) --output=$@ $(top_srcdir)/postgresql$(DISTSUFF)-setup -N

CLEANFILES=$(man_MANS) $(srcdir)/*.1
