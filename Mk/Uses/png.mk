# handle dependency on the png port
#
# Feature:	png
# Usage:	USES=png or USES=png:ARGS
# Valid ARGS:	buildrun (default), build, run
#

.if !defined(_INCLUDE_USES_PNG_MK)
_INCLUDE_USES_PNG_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS contain :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	png:single:standard
# -----------------------------------------------------
# if ARGS contain nothing or :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   png:single:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        png:single:standard
# -----------------------------------------------------

.endif
