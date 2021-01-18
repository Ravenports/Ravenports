# handle dependency on the giflib port
#
# Feature:	gif
# Usage:	USES=gif or USES=gif:ARGS
# Valid ARGS:	buildrun (default), build, run
#

.if !defined(_INCLUDE_USES_GIF_MK)
_INCLUDE_USES_GIF_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS contain :build (but not :run, :buildrun)
# BUILD_DEPENDS+=      giflib:single:standard
# -----------------------------------------------------
# if ARGS contain nothing or :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   giflib:single:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        giflib:single:standard
# -----------------------------------------------------

.endif
