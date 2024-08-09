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
# BUILD_DEPENDS+=	gettext:dev:std
# BUILD_DEPENDS+=	gettext:bldtools:std
# BUILD_DEPENDS+=	gettext:tools:std
#
#.if ! ${gettext_ARGS:Mbuild}
# BUILD_DEPENDS+=	gettext:solinks:std
# BUILDRUN_DEPENDS+=	gettext:primary:std
#.  if ${gettext_ARGS:Masprintf}
# BUILDRUN_DEPENDS+=    gettext:asprintf:std
#.  endif
#. endif
# -----------------------------------------------------

# for cargo support (only in effect with USES=cargo)
CARGO_ENV+=	GETTEXT_BIN_DIR=${LOCALBASE}/bin \
		GETTEXT_INCLUDE_DIR=${LOCALBASE}/include \
		GETTEXT_LIB_DIR=${LOCALBASE}/lib

.endif
