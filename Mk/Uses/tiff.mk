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
# BUILD_DEPENDS+=	tiff:dev:std
#.else
# BUILD_DEPENDS+=	tiff:dev:std
# BUILDRUN_DEPENDS+=	tiff:primary:std
#.endif
# -----------------------------------------------------
#
# tiff:tools:std must be explicitly lists

.endif
