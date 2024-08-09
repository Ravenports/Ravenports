# handle dependency on curl library
#
# Feature:	curl
# Usage:	USES=curl or USES=curl:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_ZSTD_MK)
_INCLUDE_USES_ZSTD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${curl_ARGS:Mbuild}
# BUILD_DEPENDS+=	curl:dev:std
#.else
# BUILD_DEPENDS+=	curl:dev:std
# BUILDRUN_DEPENDS+=	curl:primary:std
#.endif
# -----------------------------------------------

.endif
