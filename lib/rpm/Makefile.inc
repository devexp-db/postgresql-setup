rpm_macros	= %D%/macros.d/macros.$(NAME_BINARYBASE)
rpm_macros_in	= %D%/macros.d/macros.in

rpmmacros_DATA	= $(rpm_macros)

GENERATED_FILES	+= $(rpmmacros_DATA)
EXTRA_DIST	+= $(rpm_macros_in)

$(rpm_macros): $(rpm_macros_in) $(text_tpl_deps)
	$(text_tpl_gen)
