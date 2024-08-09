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
# BUILD_DEPENDS+=	zstd:dev:std
#.else
# BUILD_DEPENDS+=	zstd:dev:std
# BUILDRUN_DEPENDS+=	zstd:primary:std
#.endif
# -----------------------------------------------

.endif
