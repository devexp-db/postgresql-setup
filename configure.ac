AC_INIT([postgresql-setup], [0.9], [praiskup@redhat.com])
AM_INIT_AUTOMAKE([-Wall])
AC_CONFIG_FILES([Makefile doc/Makefile])
AC_CONFIG_FILES([postgresql-setup], [chmod +x postgresql-setup])

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

# Check for main PostgreSQL binary
# --------------------------------

AC_ARG_VAR([POSTGRES_BIN], [full path to postgres binary])
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
    README_DIST=`rpm -ql postgresql | grep README | grep dist`
    ;;
esac

test -z "$INITDB_LOG" &&
    INITDB_LOG=/var/lib/pgsql/initdb.log

test -z "$UPGRADE_LOG" &&
    UPGRADE_LOG=/var/lib/pgsql/pgupgrade.log

if test -z "$SYSCONFIG_DIR" -a "$distro_family" = redhat; then
    SYSCONFIG_DIR=/etc/sysconfig
fi

# Deal with previous versions
subst_required_var([PGVERSION],         [full PG version])
subst_required_var([PGMAJORVERSION],    [major PG version])
subst_required_var([PGENGINE],          [directory where PG server resides])
subst_required_var([PREVMAJORVERSION],  [PG major version to upgrade _from_])
subst_required_var([PREVPGENGINE],      [directory where old PG server resides])
subst_required_var([README_DIST],       [README file for distribution])
subst_required_var([INITDB_LOG],        [log file for initdb])
subst_required_var([UPGRADE_LOG],       [log file for pg_upgrade])
subst_required_var([SYSCONFIG_DIR],     [log file for pg_upgrade])

AC_OUTPUT
