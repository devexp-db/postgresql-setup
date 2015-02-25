# Use the MAJ.MIN[~SUFF].  Note that X.X > X.X~SUFF!
AC_INIT([postgresql-setup], [3.0~dev], [praiskup@redhat.com])
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
    [WANT_SYSVINIT=1],
    [WANT_SYSVINIT=0]
)

AC_ARG_WITH([upgrade-config],
    AS_HELP_STRING([--with-upgrade-config=/file/path,/path2],
                   [List of files to be used as an upgrade configuration]),
    [UPGRADE_CONFIG_LIST="$withval"],
    [UPGRADE_CONFIG_LIST="upgrade_config.template"]
)

AC_SUBST([UPGRADE_CONFIG_LIST])

AM_CONDITIONAL([WANT_SYSVINIT], [test "$WANT_SYSVINIT" -eq 1])

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
sed_subst_var_pattern(PG_CTL_BIN)
sed_subst_var_pattern(top_srcdir)
sed_subst_var_pattern(pgcontribdocdir)
sed_subst_var_pattern(PGDATADIR)
sed_subst_var_pattern(pgdocdir)
sed_subst_var_pattern(PGENGINE)
sed_subst_var_pattern(PGMAJORVERSION)
sed_subst_var_pattern(PG_UPGRADE_BIN_USER_OPT)
sed_subst_var_pattern(PGVERSION)
sed_subst_var_pattern(PKGCONFIG_DIR)
sed_subst_var_pattern(pkgname)
sed_subst_var_pattern(POSTGRES_HOMEDIR)
sed_subst_var_pattern(PREVMAJORVERSION)
sed_subst_var_pattern(PREVPGENGINE)
sed_subst_var_pattern(rawpkgdatadir)
sed_subst_var_pattern(README_DIST)
sed_subst_var_pattern(SU_POSTGRES)
sed_subst_var_pattern(systemdunitsdir)
sed_subst_var_pattern(userunitsdir)
sed_subst_var_pattern(TEST_GEN_FILES_LIST)
sed_subst_var_pattern(VERSION)
sed_subst_var_pattern(UPGRADE_CONFIG_LIST)"

m4_define([add_sed_subst_var], [
SED_RULES="$SED_RULES
sed_subst_var_pattern($1)"
])

SED_CALL="\$(SED) \$(SED_RULES)"
m4_pattern_allow(AM_V_GEN)

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

    PGMAJORVERSION=${PGVERSION%%.[[0-9]]}
fi

AX_COMPARE_VERSION([9.4], [le], [$PGVERSION],
  [PG_UPGRADE_BIN_USER_OPT="--username"],
  [PG_UPGRADE_BIN_USER_OPT="--user"])
AC_SUBST([PG_UPGRADE_BIN_USER_OPT])

# detect PGENGINE location (where the binaries are), if needed
if test -z "$PGENGINE"; then
    test -z "$ac_cv_path_POSTGRES_BIN" &&
        AC_MSG_ERROR([no postgres binary, can not detect PGENGINE])
    PGENGINE=`AS_DIRNAME($POSTGRES_BIN)`
fi

# pg_ctl binary
test -z "$PG_CTL_BIN" &&
    PG_CTL_BIN=$PGENGINE/pg_ctl
AC_SUBST([PG_CTL_BIN])

AC_PATH_PROG([PG_UPGRADE_BIN], [pg_upgrade])

# Either the PREVMAJORVERSION must be passed explicitly, or per-distro
# scripting must be done.
if test -z "$PREVMAJORVERSION"; then
    if test -z "$ac_cv_path_PG_UPGRADE_BIN"; then
        msg="pg_upgrade not found to detect \$PREVMAJORVERSION automatically"
        AC_MSG_ERROR([$msg])
    fi

    AC_MSG_CHECKING([for prev major version])
    case "$pgsetup_cv_os_family" in
    redhat)
        test -z "$ac_cv_path_PG_UPGRADE_BIN" &&
            AC_MSG_ERROR([pg_upgrade not found, plese \$PREVMAJORVERSION set])

        PREV_POSTGRES_BIN=$(rpm -ql \
            $(rpm -qf "$ac_cv_path_PG_UPGRADE_BIN") \
                | grep 'bin/postgres' )

        PREVMAJORVERSION=$(echo $PREV_POSTGRES_BIN \
            | sed 's/.*postgresql-\([[0-9\.]]\+\).*/\1/')
        ;;
    esac
    AC_MSG_RESULT($PREVMAJORVERSION)
fi

# Detect PREVPGENGINE
if test -z "$PREVPGENGINE"; then
    if test -z "$PREV_POSTGRES_BIN"; then
        AC_MSG_ERROR([can not detect \$PREV_POSTGRES_BIN])
    fi

    PREVPGENGINE=`AS_DIRNAME($PREV_POSTGRES_BIN)`
fi

if test -z "$PKGCONFIG_DIR" -a "$pgsetup_cv_os_family" = redhat; then
    PKGCONFIG_DIR=/etc/postgresql
fi

if test -z "$POSTGRES_HOMEDIR" -a "$pgsetup_cv_os_family" = redhat; then
    POSTGRES_HOMEDIR=/var/lib/pgsql
fi

if test -z "$PGDATADIR" -a "$pgsetup_cv_os_family" = redhat; then
    PGDATADIR=/var/lib/pgsql/data
fi

pgdocdir="\${datarootdir}/doc/\${pkgname}"
pgcontribdocdir="\${datarootdir}/doc/\${pkgname}-contrib"

README_DIST_BASENAME=README.rpm-dist
README_DIST="\${docdir}/$README_DIST_BASENAME"

AC_SUBST([pgdocdir])
AC_SUBST([pgcontribdocdir])
AC_SUBST([README_DIST])
AC_SUBST([README_DIST_BASENAME])

PGSETUP_SUBST_REQ([PGVERSION],         [full PG version])
PGSETUP_SUBST_REQ([PGMAJORVERSION],    [major PG version])
PGSETUP_SUBST_REQ([PGENGINE],          [directory where PG server resides])
PGSETUP_SUBST_REQ([PREVMAJORVERSION],  [PG major version to upgrade _from_])
PGSETUP_SUBST_REQ([PREVPGENGINE],      [directory where old PG server resides])
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
    Upgrade from:       $PREVMAJORVERSION
    PREV_POSTGRES_BIN:  $PREV_POSTGRES_BIN
    PostgreSQL service: $NAME_SERVICE
    PostgreSQL package: $NAME_PACKAGE
    PostgreSQL bin_pfx: $NAME_BINARYBASE
])
