HELP2MAN = $(SHELL) $(top_srcdir)/$(config_aux_dir)/missing --run help2man

# The help2man call
# =================
# Make the rules always dependant on source (thus on postgresql-setup.in, not on
# postgresql-setup), at least for distributed files.  Otherwise, the '*.1'
# manual page is regenerated even when distributed and no code change actually
# happened.  In case there exists some target generating other file directly
# depending on the generated manual page, we would need 'touch $@'.  But it
# seems better to keep warning user about non-existing help2man when '.in'
# changed.
# TODO: make it non-fatal for cross-compilation case also
# TODO: separate it to its own m4 module (for easier distribution)

HELP2MAN_RUN = \
	file=$< ; \
	file=$${file%%.in} ; \
	$(HELP2MAN) --output=$@ $$file -N ; \
	rs=$$? ; \
	if test $$rs -eq 127; then \
	    test -f $@ ; \
	else \
	    test $$rs -eq 0 ; \
	fi

dist_man_MANS = $(srcdir)/postgresql$(DISTSUFF)-setup.1

$(srcdir)/postgresql$(DISTSUFF)-setup.1: $(top_srcdir)/postgresql-setup.in
	$(AM_V_GEN)$(HELP2MAN_RUN)
