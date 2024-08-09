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
# BUILD_DEPENDS+=	expat:dev:std
#.else
# BUILD_DEPENDS+=	expat:dev:std
# BUILDRUN_DEPENDS+=	expat:primary:std
#.endif
# -----------------------------------------------

.endif
