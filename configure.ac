AC_INIT([postgresql-setup], [0.9.2~beta], [praiskup@redhat.com])
AC_CONFIG_AUX_DIR(auxdir)
config_aux_dir=auxdir
AC_SUBST([config_aux_dir])

AM_INIT_AUTOMAKE([-Wall])
AC_CONFIG_FILES([Makefile doc/Makefile])
AM_SILENT_RULES([yes])

AC_ARG_VAR([DISTSUFF], [Append string suffix to all binaries])
AC_SUBST([DISTSUFF])

# Initialize the test suite.
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_FILES([tests/Makefile])
AM_MISSING_PROG([AUTOM4TE], [autom4te])
AC_SUBST([TEST_GEN_FILES_LIST], [$\(top_srcdir\)/.generated_files])


# Instatiating generated files by sed instead of config.status.
# This is encouraged by autoconf documentation itself because if we used
# config.status directly, e.g. libexecdir may result into
# '${exec_prefix}/libexec' -- but we need fully expanded strings.
m4_define([sed_subst_var_pattern], [	-e 's|@$1[[@]]|\$($1)|g' \\])
SED_RULES="\\
sed_subst_var_pattern(bindir)
sed_subst_var_pattern(DISTSUFF)
sed_subst_var_pattern(docdir)
sed_subst_var_pattern(libdir)
sed_subst_var_pattern(libexecdir)
sed_subst_var_pattern(PG_CTL_BIN)
sed_subst_var_pattern(top_srcdir)
sed_subst_var_pattern(pgcontribdocdir)
sed_subst_var_pattern(PGDATADIR)
sed_subst_var_pattern(pgdocdir)
sed_subst_var_pattern(PGENGINE)
sed_subst_var_pattern(PGVERSION)
sed_subst_var_pattern(PGMAJORVERSION)
sed_subst_var_pattern(PKGCONFIG_DIR)
sed_subst_var_pattern(pkgname)
sed_subst_var_pattern(POSTGRES_HOMEDIR)
sed_subst_var_pattern(PREVMAJORVERSION)
sed_subst_var_pattern(PREVPGENGINE)
sed_subst_var_pattern(README_DIST)
sed_subst_var_pattern(SU)
sed_subst_var_pattern(systemdunitsdir)
sed_subst_var_pattern(userunitsdir)
sed_subst_var_pattern(TEST_GEN_FILES_LIST)
sed_subst_var_pattern(VERSION)
	-e 's|@__FILE__[[@]]|\$@|g'"

SED_CALL="\$(SED) \$(SED_RULES)"
m4_pattern_allow(AM_V_GEN)
INSTANTIATE="\$(AM_V_GEN)\$(SED_CALL) \$< > \$@"
INSTANTIATE_SCRIPT="\$(INSTANTIATE) && chmod +x \$@"
c_s='$(top_srcdir)/config.status'

AC_SUBST([SED_RULES])
AC_SUBST([SED_CALL])
AC_SUBST([INSTANTIATE])
AC_SUBST([INSTANTIATE_SCRIPT])
AC_SUBST([c_s])

AC_PATH_PROG([SED], [sed])
test -z "$ac_cv_path_SED" &&
    AC_MSG_ERROR([Sed is needed but not found.])

# For SELinux purposes use rather runuser
AC_PATH_PROG([SU], [runuser])
test -z "$ac_cv_path_SU" &&
    AC_PATH_PROG([SU], [su])
test -z "$ac_cv_path_SU" &&
    AC_MSG_ERROR([Neither 'runuser' nor 'su' program found])

distro_family=redhat
test -r /etc/redhat-release ||
    AC_MSG_ERROR([This still works for Red Hat distributions only])

# Check package manager is installed
case "$distro_family" in
redhat)
    AC_PATH_PROG([RPM], [rpm])
    test -z "$ac_cv_path_RPM" &&
        AC_MSG_ERROR([RPM package manager is required])
    ;;
esac

# Make sure that the variable is in './configure --help' output and that it is
# not empty.
m4_define([subst_required_var], [
    AC_ARG_VAR([$1], [$2])
    test -z "$[]$1" &&
        AC_MSG_ERROR([the \$$1 variable is not set])
])


# Check for main PostgreSQL binaries
# ----------------------------------

AC_ARG_VAR([POSTGRES_BIN], [Full path to postgres binary.  Note that based on
            package ownership of this file the package names (like
            postgresql-server, postgresql, ..) are detected.])
AC_PATH_PROG([POSTGRES_BIN], [postgres])


# Check for main PostgreSQL packages
# ----------------------------------

case "$distro_family" in
redhat)
    rpm_pkgname_server=$(rpm -qf $POSTGRES_BIN --qf '%{NAME}')
    rpm_pkgname=${rpm_pkgname_server%%-*}
    ;;
esac


AC_PATH_PROG([POSTGRES_BIN], [postgres])


# PGVERSION & PGMAJORVERSION
# --------------------------

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

# Detect PGENGINE location
# ------------------------

if test -z "$PGENGINE"; then
    test -z "$ac_cv_path_POSTGRES_BIN" &&
        AC_MSG_ERROR([no postgres binary, can not detect PGENGINE])
    PGENGINE=`AS_DIRNAME($POSTGRES_BIN)`
fi

# Detect pg_ctl binary
# --------------------
test -z "$PG_CTL_BIN" &&
    PG_CTL_BIN=$PGENGINE/pg_ctl
AC_SUBST([PG_CTL_BIN])


# pg_upgrade binary
# -----------------

AC_PATH_PROG([PG_UPGRADE_BIN], [pg_upgrade])

# Detect PREVMAJORVERSION
# -----------------------
# This sets as a side effect PREV_POSTGRES_BIN, which is used later on.

if test -z "$PREVMAJORVERSION"; then
    case "$distro_family" in
    redhat)
        AC_MSG_CHECKING([for prev major version])
        test -z "$ac_cv_path_PG_UPGRADE_BIN" &&
            AC_MSG_ERROR([no pg_upgrade found])

        PREV_POSTGRES_BIN=$(rpm -ql \
            $(rpm -qf "$ac_cv_path_PG_UPGRADE_BIN") \
                | grep 'bin/postgres' )

        PREVMAJORVERSION=$(echo $PREV_POSTGRES_BIN \
            | sed 's/.*postgresql-\([[0-9\.]]\+\).*/\1/')
        AC_MSG_RESULT($PREVMAJORVERSION)
        ;;
    esac
fi

# Detect PREVPGENGINE
# -------------------

if test -z "$PREVPGENGINE"; then
    PREVPGENGINE=`AS_DIRNAME($PREV_POSTGRES_BIN)`
fi

# Detect where distribution-like README is
# ----------------------------------------

case "$distro_family" in
redhat)
    test -z "$README_DIST" &&
        README_DIST=`rpm -ql postgresql | grep README | grep dist`
    ;;
esac

if test -z "$PKGCONFIG_DIR" -a "$distro_family" = redhat; then
    PKGCONFIG_DIR=/etc/postgresql
fi

if test -z "$POSTGRES_HOMEDIR" -a "$distro_family" = redhat; then
    POSTGRES_HOMEDIR=/var/lib/pgsql
fi

if test -z "$PGDATADIR" -a "$distro_family" = redhat; then
    PGDATADIR=/var/lib/pgsql/data
fi

pgdocdir="\${datarootdir}/doc/\${pkgname}"
pgcontribdocdir="\${datarootdir}/doc/\${pkgname}-contrib"
AC_SUBST([pgdocdir])
AC_SUBST([pgcontribdocdir])

# Deal with previous versions
subst_required_var([PGVERSION],         [full PG version])
subst_required_var([PGMAJORVERSION],    [major PG version])
subst_required_var([PGENGINE],          [directory where PG server resides])
subst_required_var([PREVMAJORVERSION],  [PG major version to upgrade _from_])
subst_required_var([PREVPGENGINE],      [directory where old PG server resides])
subst_required_var([README_DIST],       [README file for distribution])
subst_required_var([PKGCONFIG_DIR],     [where configuration should be stored])
subst_required_var([POSTGRES_HOMEDIR],  [full path to postgres home dir])
subst_required_var([PGDATADIR],         [full path to postgres data dir])

AC_OUTPUT
