# handle dependency on the libexecinfo library
#
# Feature:	execinfo
# Usage:	USES=execinfo
# Valid ARGS:	none or build

.if !defined(_INCLUDE_USES_EXECINFO_MK)
_INCLUDE_USES_EXECINFO_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	libexecinfo:single:standard
# if "build" argument is present:
# BUILD_DEPENDS+=	libexecinfo:single:standard
# -----------------------------------------------

.endif
