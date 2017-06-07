# handle dependency on zlib
#
# Feature:	zlib
# Usage:	USES=zlib
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_ZLIB_MK)
_INCLUDE_USES_ZLIB_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	zlib:complete:standard
# -----------------------------------------------

.endif
