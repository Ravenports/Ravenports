# handle dependency on the png port
#
# Feature:	png
# Usage:	USES=png or USES=png:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_PNG_MK)
_INCLUDE_USES_PNG_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
#.if ${png_ARGS:Mbuild}
# BUILD_DEPENDS+=	png:dev:standard
#.else
# BUILD_DEPENDS+=	png:dev:standard
# BUILDRUN_DEPENDS+=	png:primary:standard
#.endif
# -----------------------------------------------------

.endif
