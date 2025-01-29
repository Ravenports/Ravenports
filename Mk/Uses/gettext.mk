# Handle dependency on the gettext (intl library)
#
# Feature:	gettext
# Usage:	USES=gettext or USES=gettext:ARGS
# Valid ARGS:	buildrun (implicit), build, asprintf
#

.if !defined(_INCLUDE_USES_GETTEXT_MK)
_INCLUDE_USES_GETTEXT_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# BUILD_DEPENDS+=	gettext:dev:std        (except glibc)
# BUILD_DEPENDS+=	gettext:bldtools:std
# BUILD_DEPENDS+=	gettext:tools:std
#
#.if ! ${gettext_ARGS:Mbuild}
# BUILD_DEPENDS+=	gettext:solinks:std
# BUILDRUN_DEPENDS+=	gettext:primary:std    (except glibc)
#.endif
#
#.if ${gettext_ARGS:Masprintf}
# BUILD_DEPENDS+=       gettext:asprintfdev:std
# BUILDRUN_DEPENDS+=    gettext:asprintf:std
#. endif
# -----------------------------------------------------

# for cargo support (only in effect with USES=cargo)
CARGO_ENV+=	GETTEXT_BIN_DIR=${LOCALBASE}/bin

.  if !exists(/usr/include/libintl.h)
CARGO_ENV+=	GETTEXT_INCLUDE_DIR=${LOCALBASE}/include \
		GETTEXT_LIB_DIR=${LOCALBASE}/lib
.  endif

.endif
