lib		= %D%/library.sh
lib_in		= $(srcdir)/$(lib).in

pkg_tests_base	= postgresql_pkg_tests.sh
pkg_tests	= %D%/$(pkg_tests_base)
pkg_tests_in	= %D%/$(pkg_tests_base).in

_AX_TEXT_ADDITIONAL_SED_SUBSTITUTIONS += \
		-e 's|@PKG_TESTS_LIB@|$(rawpkgdatadir)/$(pkg_tests_base)|'

rawdata_generated_files = \
	$(lib) \
	$(pkg_tests)

rawdata_template_files = \
	$(lib_in) \
	$(pkg_tests_in)

rawdata_static_files =

rawpkgdata_DATA = \
	$(rawdata_generated_files) \
	$(rawdata_static_files)

GENERATED_FILES += $(rawdata_generated_files)
EXTRA_DIST += $(rawdata_static_files) $(rawdata_template_files)

$(lib): $(lib_in) $(text_tpl_deps)
	$(text_tpl_gen)

$(pkg_tests): $(pkg_tests_in)
	$(text_tpl_gen)

# vim: ft=automake noet
