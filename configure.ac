# Use the MAJ.MIN[~SUFF].  Note that X.X > X.X~SUFF!
AC_INIT([postgresql-setup], [3.1], [praiskup@redhat.com])
AC_CONFIG_AUX_DIR(auxdir)
config_aux_dir=auxdir
AC_SUBST([config_aux_dir])

AM_INIT_AUTOMAKE([-Wall])
AC_CONFIG_FILES([Makefile doc/Makefile])
AC_CONFIG_MACRO_DIR([m4])
AM_SILENT_RULES([yes])

# Initialize the test suite.
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_FILES([tests/Makefile])
AM_MISSING_PROG([AUTOM4TE], [autom4te])
AC_SUBST([TEST_GEN_FILES_LIST], [.generated_files])

# TODO: detect systemd/sysvinit.  Also, we should probably be able to install
# both configuration at once when needed.
AC_ARG_WITH([sysvinit],
    AS_HELP_STRING([--with-sysvinit],
                   [prepares sys v init script]),
    [WANT_SYSVINIT=0
     test x"$withval" = xyes && WANT_SYSVINIT=1]
)

if test x = x"$WANT_SYSVINIT"
then
    WANT_SYSVINIT=0
    # Try to detect system running systemd
    AC_PATH_PROG([SYSTEMCTL], [systemctl])
    test -z "$ac_cv_path_SYSTEMCTL" && WANT_SYSVINIT=1
fi

INIT_SYSTEM=systemd
test x"$WANT_SYSVINIT" = x1 && INIT_SYSTEM=sysvinit

AM_CONDITIONAL([WANT_SYSVINIT], [test "$WANT_SYSVINIT" -eq 1])
AC_SUBST([WANT_SYSVINIT])

# Instatiating generated files by sed instead of config.status.
# This is encouraged by autoconf documentation itself because if we used
# config.status directly, e.g. libexecdir may result into
# '${exec_prefix}/libexec' -- but we need fully expanded strings.
m4_define([sed_subst_var_pattern], [	-e 's|@$1[[@]]|\$($1)|g' \\])
SED_RULES="\\
sed_subst_var_pattern(bindir)
sed_subst_var_pattern(docdir)
sed_subst_var_pattern(libdir)
sed_subst_var_pattern(libexecdir)
sed_subst_var_pattern(top_srcdir)
sed_subst_var_pattern(PGDATADIR)
sed_subst_var_pattern(PGMAJORVERSION)
sed_subst_var_pattern(PG_UPGRADE_BIN_USER_OPT)
sed_subst_var_pattern(PGVERSION)
sed_subst_var_pattern(PKGCONFIG_DIR)
sed_subst_var_pattern(POSTGRES_HOMEDIR)
sed_subst_var_pattern(README_DIST)
sed_subst_var_pattern(SU_POSTGRES)
sed_subst_var_pattern(sysconfdir)
sed_subst_var_pattern(TEST_GEN_FILES_LIST)
sed_subst_var_pattern(VERSION)
sed_subst_var_pattern(WANT_SYSVINIT)"

m4_define([add_sed_subst_var], [
SED_RULES="$SED_RULES
sed_subst_var_pattern($1)"
AC_SUBST($1)
])

m4_define([conf_dir], [dnl
test -z "$$1" && $1=$2
add_sed_subst_var($1)
])

SED_CALL="\$(SED) \$(SED_RULES)"
m4_pattern_allow(AM_V_GEN)

conf_dir([systemdunitsdir],          ['${prefix}/lib/systemd/system'])
conf_dir([systemduserunitsdir],      ['${prefix}/etc/systemd/system'])
conf_dir([systemdlegacyscriptsdir],  ['${libexecdir}/initscripts/legacy-actions'])
conf_dir([initscriptsdir],           ['${sysconfdir}/rc.d/init.d'])
conf_dir([initscriptsconfdir],       ['/etc/sysconfig/pgsql'])
conf_dir([rawpkgdatadir],            ['${datadir}/postgresql-setup'])
conf_dir([pgdocdir],                 ['${datarootdir}/doc/${NAME_PACKAGE}'])
conf_dir([pgcontribdocdir],          ['${datarootdir}/doc/${NAME_PACKAGE}-contrib'])

INSTANTIATE_CONV="\$(AM_V_GEN)rm -rf \$@; \$(MKDIR_P) \$(@D)"
INSTANTIATE="\$(INSTANTIATE_CONV) && \$(SED_CALL) \$< > \$@ && chmod -w \$@"
INSTANTIATE_SCRIPT="\$(INSTANTIATE) && chmod +x \$@"
c_s='$(top_builddir)/config.status'

AC_SUBST([SED_CALL])
AC_SUBST([INSTANTIATE])
AC_SUBST([INSTANTIATE_CONV])
AC_SUBST([INSTANTIATE_SCRIPT])
AC_SUBST([c_s])


AC_PATH_PROG([SED], [sed])
test -z "$ac_cv_path_SED" &&
    AC_MSG_ERROR([Sed is needed but not found.])

AC_PATH_PROGS([SU], [runuser su])
test -z "$ac_cv_path_SU" &&
    AC_MSG_ERROR([Neither 'runuser' nor 'su' program found])
SU_POSTGRES="$SU -s /bin/sh -l postgres"
AC_SUBST([SU_POSTGRES])

PGSETUP_PACKAGING_INIT

# check for main PostgreSQL binaries
AC_ARG_VAR([POSTGRES_BIN], [Full path to postgres binary.  Note that based on
            package ownership of this file the package names (like
            postgresql-server, postgresql, ..) are detected.])
AC_PATH_PROG([POSTGRES_BIN], [postgres])

# check for PGVERSION & PGMAJORVERSION, if needed
if test -z "$PGVERSION" -a -z "$PGMAJORVERSION"; then
    test -z "$ac_cv_path_POSTGRES_BIN" &&
        AC_MSG_ERROR([no postgres binary, can not detect version])

    AC_MSG_CHECKING([for full version PostgreSQL server])
    raw_version=$("$POSTGRES_BIN" --version) ||
        AC_MSG_ERROR([command $POSTGRES_BIN --version failed])

    PGVERSION=${raw_version##* }
    AC_MSG_RESULT($PGVERSION)

    PGMAJORVERSION=`echo $PGVERSION | sed 's/\.[0-9]\+$//'`
fi

AX_COMPARE_VERSION([9.4], [le], [$PGVERSION],
  [PG_UPGRADE_BIN_USER_OPT="--username"],
  [PG_UPGRADE_BIN_USER_OPT="--user"])
AC_SUBST([PG_UPGRADE_BIN_USER_OPT])

AC_PATH_PROG([PG_UPGRADE_BIN], [pg_upgrade])

if test -z "$PKGCONFIG_DIR" -a "$pgsetup_cv_os_family" = redhat; then
    PKGCONFIG_DIR=/etc/postgresql
fi

if test -z "$POSTGRES_HOMEDIR" -a "$pgsetup_cv_os_family" = redhat; then
    POSTGRES_HOMEDIR=/var/lib/pgsql
fi

if test -z "$PGDATADIR" -a "$pgsetup_cv_os_family" = redhat; then
    # This is based on Red Hat's packaging.
    PGDATADIR='${localstatedir}/lib/pgsql/data'
fi

README_DIST_BASENAME=README.rpm-dist
README_DIST="\${pgdocdir}/$README_DIST_BASENAME"

AC_SUBST([README_DIST])
AC_SUBST([README_DIST_BASENAME])

PGSETUP_SUBST_REQ([PGVERSION],         [full PG version])
PGSETUP_SUBST_REQ([PGMAJORVERSION],    [major PG version])
PGSETUP_SUBST_REQ([PKGCONFIG_DIR],     [where configuration should be stored])
PGSETUP_SUBST_REQ([POSTGRES_HOMEDIR],  [full path to postgres home dir])
PGSETUP_SUBST_REQ([PGDATADIR],         [full path to postgres data dir])

PGSETUP_SUBST_OPT([NAME_SRV_PFX], [],
                  [service name prefix, like (PFX)postgresql.service])
PGSETUP_SUBST_OPT([NAME_SRV_SFX], [],
                  [service name suffix, like postgresql(SFX).service ])
PGSETUP_SUBST_OPT([NAME_BIN_SFX], [],
                  [binary name prefix, like (PFX)postgresql-setup])
PGSETUP_SUBST_OPT([NAME_BIN_SFX], [],
                  [binary name suffix, like postgresql(SFX)-setup])
PGSETUP_SUBST_OPT([NAME_PKG_PFX], [],
                  [package name prefix, like (PFX)postgresql.rpm])
PGSETUP_SUBST_OPT([NAME_PKG_SFX], [],
                  [package name suffix, like postgresql(SFX).rpm])
PGSETUP_SUBST_OPT([NAME_DEFAULT_PREV_SERVICE], [postgresql],
                  [name of service to upgrade from by default (defaults to
                   'postgresql'])

PGSETUP_SUBST_OPT([SCLS], [],
                  [mention software collections which should be enabled
                   for all binaries from ${bindir}])

SCL_BINDIR=/usr/bin
SCL_BINARY=scl
SCL_SOURCE=
SCL_SHELL_WRAPPER=
if test -n "$SCLS"
then
    SCL_SHELL_WRAPPER="$SCL_BINDIR/$SCL_BINARY enable $SCLS -- "
    SCL_SOURCE="source scl_source enable $SCLS ;"
fi
add_sed_subst_var(SCL_SHELL_WRAPPER)
add_sed_subst_var(SCL_SOURCE)

NAME_BINARYBASE="$NAME_BIN_PFX""postgresql$NAME_BIN_SFX"
NAME_PACKAGE="$NAME_PKG_PFX""postgresql$NAME_PKG_SFX"
NAME_SERVICE="$NAME_SRV_PFX""postgresql$NAME_SRV_SFX"

AC_SUBST([NAME_BINARYBASE])
AC_SUBST([NAME_PACKAGE])
AC_SUBST([NAME_SERVICE])

AC_SUBST([NAME_BINARYBASE])
AC_SUBST([NAME_PACKAGE])
AC_SUBST([NAME_SERVICE])

add_sed_subst_var(NAME_SERVICE)
add_sed_subst_var(NAME_PACKAGE)
add_sed_subst_var(NAME_BINARYBASE)

# As late as possible.
SED_RULES="$SED_RULES
	-e 's|@__FILE__[[@]]|\$@|g'"
AC_SUBST([SED_RULES])

AC_OUTPUT

AC_MSG_NOTICE([Configured the folowing way:

    PostgreSQL version: $PGVERSION
    PGDATADIR:          $PGDATADIR
    PostgreSQL service: $NAME_SERVICE
    PostgreSQL package: $NAME_PACKAGE
    PostgreSQL bin_pfx: $NAME_BINARYBASE
    Init system:        $INIT_SYSTEM
])
