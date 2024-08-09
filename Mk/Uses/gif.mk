# handle dependency on the giflib port
#
# Feature:	gif
# Usage:	USES=gif or USES=gif:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_GIF_MK)
_INCLUDE_USES_GIF_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
#.if ${gif_ARGS:Mbuild}
# BUILD_DEPENDS+=	giflib:dev:std
#.else
# BUILD_DEPENDS+=	giflib:dev:std
# BUILDRUN_DEPENDS+=	giflib:primary:std
#.endif
# -----------------------------------------------------

.endif
