# handle dependency on freetype
#
# Feature:	freetype
# Usage:	USES=freetype or USES=freetype:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_ZSTD_MK)
_INCLUDE_USES_ZSTD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${freetype_ARGS:Mbuild}
# BUILD_DEPENDS+=	freetype:dev:standard
#.else
# BUILD_DEPENDS+=	freetype:dev:standard
# BUILDRUN_DEPENDS+=	freetype:primary:standard
#.endif
# -----------------------------------------------

.endif
