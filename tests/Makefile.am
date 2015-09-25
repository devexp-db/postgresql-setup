EXTRA_DIST = testsuite.at \
	     package.m4 \
	     $(TESTSUITE) \
	     atlocal.in

$(srcdir)/package.m4: $(top_srcdir)/configure.ac
	$(AM_V_GEN):;{ \
	    echo '# Signature of the current package.' && \
	    echo 'm4_define([AT_PACKAGE_NAME],' && \
	    echo ' [$(PACKAGE_NAME)])' && \
	    echo 'm4_define([AT_PACKAGE_TARNAME],' && \
	    echo ' [$(PACKAGE_TARNAME)])' && \
	    echo 'm4_define([AT_PACKAGE_VERSION],' && \
	    echo ' [$(PACKAGE_VERSION)])' && \
	    echo 'm4_define([AT_PACKAGE_STRING],' && \
	    echo ' [$(PACKAGE_STRING)])' && \
	    echo 'm4_define([AT_PACKAGE_BUGREPORT],' && \
	    echo ' [$(PACKAGE_BUGREPORT)])'; \
	    echo 'm4_define([AT_PACKAGE_URL],' && \
	    echo ' [$(PACKAGE_URL)])'; \
	} >'$(srcdir)/package.m4'

TESTSUITE = $(srcdir)/testsuite
CHECK_DEPS = atconfig atlocal $(TESTSUITE) $(top_builddir)/$(TEST_GEN_FILES_LIST)

atlocal: atlocal.in $(c_s)
	$(text_tpl_gen)

check-local: $(CHECK_DEPS)
	$(SHELL) '$(TESTSUITE)' $(TESTSUITEFLAGS)

installcheck-local: $(CHECK_DEPS)
	$(SHELL) '$(TESTSUITE)' AUTOTEST_PATH='$(bindir)' $(TESTSUITEFLAGS)

clean-local:
	test ! -f '$(TESTSUITE)' || \
	    $(SHELL) '$(TESTSUITE)' --clean

AUTOTEST = $(AUTOM4TE) --language=autotest

$(TESTSUITE): $(srcdir)/testsuite.at $(srcdir)/package.m4
	$(AM_V_GEN)$(AUTOTEST) -I '$(srcdir)' -o $@.tmp $@.at && \
	mv $@.tmp $@

DISTCLEANFILES = atconfig atlocal
