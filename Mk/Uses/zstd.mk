# handle dependency on Zstandard
#
# Feature:	zstd
# Usage:	USES=zstd or USES=zstd:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_ZSTD_MK)
_INCLUDE_USES_ZSTD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {zstd_ARGS:Mbuild}
# BUILD_DEPENDS+=	Zstandard:static:standard
#.else
# BUILD_DEPENDS+=	Zstandard:static:standard
# BUILDRUN_DEPENDS+=	Zstandard:shared:standard
#.endif
# -----------------------------------------------

.endif
