rpm_macros	= %D%/macros.d/macros.$(NAME_SERVICE)
rpm_macros_in	= %D%/macros.d/macros.in

rpm_macros_test		= %D%/macros.d/macros.$(NAME_SERVICE)-test
rpm_macros_test_in	= %D%/macros.d/macros-test.in

rpmmacros_DATA	= $(rpm_macros) $(rpm_macros_test)

GENERATED_FILES	+= $(rpmmacros_DATA)
EXTRA_DIST	+= $(rpm_macros_in) $(rpm_macros_test_in)

$(rpm_macros): $(rpm_macros_in) $(text_tpl_deps)
	$(text_tpl_gen)

$(rpm_macros_test): $(rpm_macros_test_in) $(text_tpl_deps)
	$(text_tpl_gen)
if COMPAT_MACROS
	@chmod +w "$@" ; ( \
	echo ; \
	compat() { echo %$$1 echo "2>&1" WARN: macro $$1 will be removed, use $$2 ";" %$$2 ; } ; \
	compat pgtests_init @NAME_SERVICE_VARNAME@_tests_init >> "$@" ; \
	compat pgtests_start @NAME_SERVICE_VARNAME@_tests_start >> "$@" ; \
	) >> "$@" && chmod -w "$@"
endif
