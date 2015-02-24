config_builder =  $(top_srcdir)/%D%/build-config

noinst_SCRIPT = $(config_builder)

EXTRA_DIST += $(noinst_SCRIPT)

# vim: ft=automake noet
