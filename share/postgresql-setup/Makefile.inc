lib		= %D%/library.sh
lib_in		= $(srcdir)/$(lib).in

rawdata_generated_files = \
	$(lib)

rawdata_template_files = \
	$(lib_in)

rawdata_static_files =

rawpkgdata_DATA = \
	$(rawdata_generated_files)

GENERATED_FILES += $(rawdata_generated_files)
EXTRA_DIST += $(rawdata_static_files) $(rawdata_template_files)

$(lib): $(lib_in) $(c_s)
	$(text_tpl_gen)

# vim: ft=automake noet
