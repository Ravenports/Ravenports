# handle dependency on the jpeg port
#
# Feature:	jpeg
# Usage:	USES=jpeg or USES=jpeg:ARGS
# Valid ARGS:	buildrun (default), build, run
#

.if !defined(_INCLUDE_USES_JPEG_MK)
_INCLUDE_USES_JPEG_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS contain :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	jpeg-turbo:primary:standard
# -----------------------------------------------------
# if ARGS contain nothing or :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   jpeg-turbo:primary:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        jpeg-turbo:primary:standard
# -----------------------------------------------------

.endif
