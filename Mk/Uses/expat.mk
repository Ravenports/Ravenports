# handle dependency on expat
#
# Feature:	expat
# Usage:	USES=expat or USES=expat:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_EXPAT_MK)
_INCLUDE_USES_EXPAT_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {expat_ARGS:Mbuild}
# BUILD_DEPENDS+=	expat:static:standard
#.else
# BUILD_DEPENDS+=	expat:static:standard
# BUILDRUN_DEPENDS+=	expat:shared:standard
#.endif
# -----------------------------------------------

.endif
