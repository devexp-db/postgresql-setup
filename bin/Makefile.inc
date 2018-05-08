setup		= %D%/$(NAME_BINARYBASE)-setup
setup_in	= %D%/postgresql-setup.in

postgresql_upgrade = %D%/$(NAME_BINARYBASE)-upgrade
postgresql_upgrade_in = %D%/$(NAME_BINARYBASE)-upgrade.in

bin_SCRIPTS = $(setup) $(postgresql_upgrade)

$(setup): $(setup_in) $(text_tpl_deps)
	$(text_tpl_gen_script)

$(postgresql_upgrade): $(postgresql_upgrade_in) $(text_tpl_deps)
	$(text_tpl_gen_script)

EXTRA_DIST += $(setup_in) $(postgresql_upgrade_in)
