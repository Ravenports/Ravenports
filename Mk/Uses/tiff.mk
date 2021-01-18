# handle dependency on the tiff port
#
# Feature:	tiff
# Usage:	USES=tiff or USES=tiff:ARGS
# Valid ARGS:	buildrun (default), build, run
#

.if !defined(_INCLUDE_USES_TIFF_MK)
_INCLUDE_USES_TIFF_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS contain :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	tiff:primary:standard
# -----------------------------------------------------
# if ARGS contain nothing or :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   tiff:primary:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        tiff:primary:standard
# -----------------------------------------------------

.endif
