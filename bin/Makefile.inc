setup		= %D%/$(NAME_BINARYBASE)-setup
setup_in	= %D%/postgresql-setup.in

bin_SCRIPTS = $(setup)

$(setup): $(setup_in) $(text_tpl_deps)
	$(text_tpl_gen_script)

EXTRA_DIST += $(setup_in)
