newunit		= %D%/$(NAME_BINARYBASE)-new-systemd-unit
newunit_in	= %D%/new-systemd-unit.in

if ! WANT_SYSVINIT
sbin_SCRIPTS = $(newunit)
endif

$(newunit): $(newunit_in) $(text_tpl_deps)
	$(text_tpl_gen_script)

EXTRA_DIST += $(newunit_in)
