# handle dependency on Zstandard
#
# Feature:	zstd
# Usage:	USES=zstd or USES=zstd:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_ZSTD_MK)
_INCLUDE_USES_ZSTD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${zstd_ARGS:Mbuild}
# BUILD_DEPENDS+=	zstd:dev:standard
#.else
# BUILD_DEPENDS+=	zstd:dev:standard
# BUILDRUN_DEPENDS+=	zstd:primary:standard
#.endif
# -----------------------------------------------

.endif
