HELP2MAN = $(SHELL) $(top_srcdir)/$(config_aux_dir)/missing --run help2man

dist_man_MANS = $(srcdir)/postgresql-setup.1

$(srcdir)/postgresql-setup.1: $(top_srcdir)/postgresql-setup.in
	@echo "Updating the man page '$@'"; \
	$(HELP2MAN) --output=$@ $(top_srcdir)/postgresql-setup -N
