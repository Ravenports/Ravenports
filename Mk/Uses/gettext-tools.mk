# Handle dependency on the gettext-tools port
#
# Feature:	gettext-tools
# Usage:	USES=gettext-tools or USES=gettext-tools:ARGS
# Valid ARGS:	build (default), run, buildrun
#

.if !defined(_INCLUDE_USES_GETTEXT_TOOLS_MK)
_INCLUDE_USES_GETTEXT_TOOLS_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# if ARGS are none or :build (and no others)
# BUILD_DEPENDS+=	gettext:tools:standard
# -----------------------------------------------
# if ARGS contain :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   gettext:tools:standard
# -----------------------------------------------
# if ARGS contains only :run
# RUN_DEPENDS+=        gettext:tools:standard
# -----------------------------------------------
 
.endif
