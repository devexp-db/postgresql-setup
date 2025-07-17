# Use the MAJ.MIN[~SUFF].  Note that X.X > X.X~SUFF!
AC_INIT([postgresql-setup], [8.10~dev], [praiskup@redhat.com])
AC_CONFIG_AUX_DIR(auxdir)
config_aux_dir=auxdir
AC_SUBST([config_aux_dir])

AM_INIT_AUTOMAKE([-Wall])
AC_CONFIG_FILES([Makefile])
AC_CONFIG_MACRO_DIR([m4])
AM_SILENT_RULES([yes])

# Initialize the test suite.
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_FILES([tests/Makefile])
AM_MISSING_PROG([AUTOM4TE], [autom4te])

_AX_TEXT_TPL_INIT

_AX_TEXT_TPL_SUBST([TEST_GEN_FILES_LIST], [.generated_files])

WANT_SYSVINIT=0
INIT_SYSTEM=systemd
INIT_SYSTEM_SERVICE_PATH=/lib/systemd/system
test -d /usr/lib/systemd/system/ || {
    INIT_SYSTEM=sysvinit
    WANT_SYSVINIT=1
    INIT_SYSTEM_SERVICE_PATH=
}
AM_CONDITIONAL([WANT_SYSVINIT], [test "$WANT_SYSVINIT" -eq 1])
_AX_TEXT_TPL_SUBST([WANT_SYSVINIT])

m4_define([conf_dir], [dnl
test -z "$$1" && $1=$2
_AX_TEXT_TPL_SUBST([$1])
])

SED_CALL="\$(SED) \$(SED_RULES)"
m4_pattern_allow(AM_V_GEN)

AC_CACHE_CHECK(
    [for rpmmacrosdir], [my_cv_macrosdir], [
        my_cv_macrosdir=/etc/rpm
        if test -n "$rpmmacrosdir"; then
            check_dir=$rpmmacrosdir
        else
            check_dir=`rpm --eval %_rpmconfigdir/macros.d 2>/dev/null ||:`
        fi
        test -d "$check_dir" && my_cv_macrosdir=$check_dir
    ]
)

conf_dir([rpmmacrosdir],             [$my_cv_macrosdir])
conf_dir([systemdunitsdir],          ['/usr/lib/systemd/system'])
conf_dir([systemduserunitsdir],      ['/etc/systemd/system'])
conf_dir([systemdlegacyscriptsdir],  ['/usr/libexec/initscripts/legacy-actions'])
conf_dir([initscriptsdir],           ['/etc/rc.d/init.d'])
conf_dir([initscriptsconfdir],       ['/etc/sysconfig/pgsql'])
conf_dir([rawpkgdatadir],            ['${datadir}/postgresql-setup'])
# Those two should be specified explicitly.
conf_dir([pgdocdir],                 ['${datarootdir}/doc/${NAME_PACKAGE}'])
conf_dir([pgcontribdocdir],          ['${datarootdir}/doc/${NAME_PACKAGE}-contrib'])

INSTANTIATE_CONV="\$(AM_V_GEN)rm -rf \$@; \$(MKDIR_P) \$(@D)"
INSTANTIATE="\$(INSTANTIATE_CONV) && \$(SED_CALL) \$< > \$@ && chmod -w \$@"
INSTANTIATE_SCRIPT="\$(INSTANTIATE) && chmod +x \$@"

AC_PATH_PROG([SED], [sed])
test -z "$ac_cv_path_SED" &&
    AC_MSG_ERROR([Sed is needed but not found.])

AC_PATH_PROGS([SU], [runuser su])
test -z "$ac_cv_path_SU" &&
    AC_MSG_ERROR([Neither 'runuser' nor 'su' program found])

PGSETUP_SUBST_OPT([PGADMINUSER], [postgres],
                  [System-default PostgreSQL admin username])
SU_POSTGRES="$SU -s /bin/sh -l $PGADMINUSER"
_AX_TEXT_TPL_SUBST([SU_POSTGRES])

AC_PATH_PROG([MOUNTPOINT], [mountpoint], [false])
_AX_TEXT_TPL_SUBST([MOUNTPOINT])

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

    PGMAJORVERSION=`echo $PGVERSION | $SED 's/\.[[0-9]]\+$//'`
fi

AX_COMPARE_VERSION([9.4], [le], [$PGVERSION],
  [PG_UPGRADE_BIN_USER_OPT="--username"],
  [PG_UPGRADE_BIN_USER_OPT="--user"])
_AX_TEXT_TPL_SUBST([PG_UPGRADE_BIN_USER_OPT])

PGLOGDIR_BASENAME=log
AX_COMPARE_VERSION([10], [gt], [$PGVERSION],
  [PGLOGDIR_BASENAME=pg_log])
_AX_TEXT_TPL_SUBST([PGLOGDIR_BASENAME])

AC_PATH_PROG([PG_UPGRADE_BIN], [pg_upgrade])

if test -z "$PKGCONFIG_DIR"; then
   case $pgsetup_cv_os_family in
   redhat|fedora|amazon)
     PKGCONFIG_DIR=/etc/postgresql
     ;;
   esac
fi

if test -z "$POSTGRES_HOMEDIR"; then
   case $pgsetup_cv_os_family in
   redhat|fedora|amazon)
     POSTGRES_HOMEDIR=/var/lib/pgsql
     ;;
   esac
fi

if test -z "$PGDATADIR"; then
   case $pgsetup_cv_os_family in
   redhat|fedora|amazon)
     # This is based on Red Hat's packaging.
     PGDATADIR='${localstatedir}/lib/pgsql/data'
     ;;
   esac
fi

README_DIST_BASENAME=README.rpm-dist
README_DIST="\${pgdocdir}/$README_DIST_BASENAME"

_AX_TEXT_TPL_SUBST([README_DIST])
_AX_TEXT_TPL_SUBST([README_DIST_BASENAME])

PGSETUP_SUBST_REQ([PGVERSION],         [full PG version])
PGSETUP_SUBST_REQ([PGMAJORVERSION],    [major PG version])
PGSETUP_SUBST_REQ([PKGCONFIG_DIR],     [where configuration should be stored])
PGSETUP_SUBST_REQ([POSTGRES_HOMEDIR],  [full path to postgres home dir])
PGSETUP_SUBST_REQ([PGDATADIR],         [full path to postgres data dir])

SCL_BINDIR=/usr/bin
SCL_BINARY=scl
SCL_SOURCE=:
SCL_SHELL_WRAPPER=

scl_enabled_build=false
AC_ARG_WITH([scl],
            [AS_HELP_STRING([--with-scl],
                            [Build against Software Collections RPM])],
            [scl_enabled_build=:])

SYSTEMD_EXECSTART='${bindir}/postgres -D $${PGDATA}'

if $scl_enabled_build; then
    AC_MSG_CHECKING([which SCL to build against])
    SCL=`rpm --eval %scl`
    if test x"$SCL" = x%scl; then
        AC_MSG_ERROR([Macro %scl undefined, please install COLLECTION-build subpackage])
    else
        SCL_SHELL_WRAPPER="$SCL_BINDIR/$SCL_BINARY enable $SCL -- "
        SCL_SOURCE="source scl_source enable $SCL"
        AC_MSG_RESULT([$SCL])

        SYSTEMD_EXECSTART="/bin/sh -c '\''source scl_source enable ${SCL} ; exec postmaster -D \$\${PGDATA}'\''"

        # The variables below override the detected default here.
        test x = x"$NAME_SRV_PFX" && NAME_SRV_PFX=$SCL-
        test x = x"$NAME_PKG_PFX" && NAME_PKG_PFX=$SCL-
    fi
fi

AC_ARG_WITH([libs-pkg],
            [AS_HELP_STRING([--without-libs-pkg],
                            [PostgreSQL installation will not have postgresql-libs])],
            [], [withval=yes])
_AX_TEXT_TPL_SUBST([LIBS_ENABLED], [$withval])

PGSETUP_SUBST_OPT([MODULE_COMPAT_SUFFIX], [],
                  [add suffix to module provides in %postgresql_module_requires])
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
PGSETUP_SUBST_OPT([rpmmacrosdir], [],
                  [where to install rpm macros files])


_AX_TEXT_TPL_SUBST([SCL_SHELL_WRAPPER])
_AX_TEXT_TPL_SUBST([SCL_SOURCE])
_AX_TEXT_TPL_SUBST([SYSTEMD_EXECSTART])

NAME_BINARYBASE="$NAME_BIN_PFX""postgresql$NAME_BIN_SFX"
NAME_PACKAGE="$NAME_PKG_PFX""postgresql$NAME_PKG_SFX"
NAME_SERVICE="$NAME_SRV_PFX""postgresql$NAME_SRV_SFX"
NAME_SERVICE_VARNAME=`echo "$NAME_SERVICE" | $SED 's/-/_/g'`

_AX_TEXT_TPL_SUBST([NAME_BINARYBASE])
_AX_TEXT_TPL_SUBST([NAME_PACKAGE])
_AX_TEXT_TPL_SUBST([NAME_SERVICE])
_AX_TEXT_TPL_SUBST([NAME_SERVICE_VARNAME])
_AX_TEXT_TPL_SUBST([INIT_SYSTEM_SERVICE_PATH])

AC_MSG_CHECKING([whether to install compat %pgtest_* macros])
# This hack shouldn't be removed sooner than once the F27 postgresql is EOL,
# since taht's probably the last Fedora release where %pgtest_* macros were
# used by default.
COMPAT_MACROS=no
test "$NAME_SERVICE" = postgresql && COMPAT_MACROS=yes
AC_MSG_RESULT($COMPAT_MACROS)
AM_CONDITIONAL([COMPAT_MACROS], [test "$COMPAT_MACROS" = yes])

AC_OUTPUT

AC_MSG_NOTICE([Configured the folowing way:

    PostgreSQL version:    $PGVERSION
    PGDATADIR:             $PGDATADIR
    PostgreSQL service:    $NAME_SERVICE
    PostgreSQL package:    $NAME_PACKAGE
    PostgreSQL bin_pfx:    $NAME_BINARYBASE
    Init system:           $INIT_SYSTEM
    Init system services:  $INIT_SYSTEM_SERVICE_PATH
])
