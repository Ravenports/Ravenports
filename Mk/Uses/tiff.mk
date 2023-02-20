# handle dependency on the tiff port
#
# Feature:	tiff
# Usage:	USES=tiff or USES=tiff:ARGS
# Valid ARGS:	buildrun (default), build
#

.if !defined(_INCLUDE_USES_TIFF_MK)
_INCLUDE_USES_TIFF_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
#.if ${tiff_ARGS:Mbuild}
# BUILD_DEPENDS+=	tiff:dev:standard
#.else
# BUILD_DEPENDS+=	tiff:dev:standard
# BUILDRUN_DEPENDS+=	tiff:primary:standard
#.endif
# -----------------------------------------------------
#
# tiff:tools:standard must be explicitly lists

.endif
