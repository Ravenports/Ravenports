# handle dependency on the jpeg port
#
# Feature:	jpeg
# Usage:	USES=jpeg or USES=jpeg:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_JPEG_MK)
_INCLUDE_USES_JPEG_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
#.if {jpeg_ARGS:Mbuild}
# BUILD_DEPENDS+=	jpeg-turbo:dev:standard
#.else
# BUILD_DEPENDS+=	jpeg-turbo:dev:standard
# BUILDRUN_DEPENDS+=	jpeg-turbo:primary:standard
#.endif
# -----------------------------------------------------

.endif
