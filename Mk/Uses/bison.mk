# handle dependency on the bison port
#
# Feature:	bison
# Usage:	USES=bison or USES=bison:ARGS
# Valid ARGS:	build (default), buildrun, run
#

.if !defined(_INCLUDE_USES_BISON_MK)
_INCLUDE_USES_BISON_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS are none or :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	bison:primary:standard
# -----------------------------------------------------
# if ARGS contain :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   bison:primary:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        bison:primary:standard
# -----------------------------------------------------

.endif
