# Handle dependency on the gettext-tools port
#
# Feature:	gettext-tools
# Usage:	USES=gettext-tools or USES=gettext-tools:ARGS
# Valid ARGS:	build (default), buildrun, run
#

.if !defined(_INCLUDE_USES_GETTEXT_TOOLS_MK)
_INCLUDE_USES_GETTEXT_TOOLS_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS are none or :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	gettext:tools:standard
# -----------------------------------------------------
# if ARGS contain :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   gettext:tools:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        gettext:tools:standard
# -----------------------------------------------------

.endif
