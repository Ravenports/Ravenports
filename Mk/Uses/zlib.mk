# handle dependency on zlib
#
# Feature:	zlib
# Usage:	USES=zlib
# Valid ARGS:	buildrun (default, implicit), build

.if !defined(_INCLUDE_USES_ZLIB_MK)
_INCLUDE_USES_ZLIB_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {zlib_ARGS:Mbuild}
# BUILD_DEPENDS+=	zlib:dev:std
#.else
# BUILD_DEPENDS+=	zlib:dev:std
# BUILDRUN_DEPENDS+=	zlib:primary:std
#.endif
# -----------------------------------------------

.endif
