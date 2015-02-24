upgrade_config		= %D%/upgrade.conf

rawpkgdatadir = $(datadir)/postgresql-setup
rawpkgdata_DATA = \
	$(upgrade_config)

$(UPGRADE_CONFIG_LIST):
	@echo "  error: config file '$@' does not exist" && false

$(upgrade_config): $(UPGRADE_CONFIG_LIST) $(c_s)
	$(INSTANTIATE_CONV) \
	    && $(config_builder) "$(UPGRADE_CONFIG_LIST)" > $@

GENERATED_FILES += $(upgrade_config)

# vim: ft=automake noet
