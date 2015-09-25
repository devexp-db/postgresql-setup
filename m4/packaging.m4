AC_DEFUN([PGSETUP_PACKAGING_INIT], [
  AC_CACHE_CHECK(
    [for oprating system (distribution)],
    [pgsetup_cv_os_family], [
      pgsetup_cv_os_family=
      if test -r /etc/redhat-release; then
        pgsetup_cv_os_family=redhat
      fi
    ]
  )

  case $pgsetup_cv_os_family in
  redhat)
    AC_PATH_PROG([RPM], [rpm])
    if test -z "$ac_cv_path_RPM"; then
      AC_MSG_ERROR("can not find RPM package manager")
    fi
    ;;
  *)
    AC_MSG_ERROR([rpm distro only ATM (todo)])
    ;;
  esac
])

# PGSETUP_SUBST_REQ(VARIABLE,DESCRIPTION)
# ---------------------------------------
# Make sure that the VARIABLE is mentioned in './configure --help' output and
# that it is not empty after processing this macro.  Use the DESCRIPTION as a
# comment.
m4_define([PGSETUP_SUBST_REQ], [
    AC_ARG_VAR([$1], [$2])
    _AX_TEXT_TPL_SUBST([$1])
    test -z "$[]$1" &&
        AC_MSG_ERROR([the \$$1 variable is not set])
])

# PGSETUP_SUBST_OPT(VARIABLE, DEFAULT, DESCRIPTION)
# -------------------------------------------------
m4_define([PGSETUP_SUBST_OPT], [
    AC_ARG_VAR([$1], [$3])
    test -z "$[]$1" &&
        $1=$2
    _AX_TEXT_TPL_SUBST($1)
])
