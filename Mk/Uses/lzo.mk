# handle dependency on lzo
#
# Feature:	lzo
# Usage:	USES=lzo or USES=lzo:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_LZO_MK)
_INCLUDE_USES_LZO_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {lzo_ARGS:Mbuild}
# BUILD_DEPENDS+=	lzo:static:standard
#.else
# BUILD_DEPENDS+=	lzo:static:standard
# BUILDRUN_DEPENDS+=	lzo:shared:standard
#.endif
# -----------------------------------------------

.endif
