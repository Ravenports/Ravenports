# handle dependency on fontconfig
#
# Feature:	expat
# Usage:	USES=fontconfig or USES=fontconfig:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_FONTCONFIG_MK)
_INCLUDE_USES_FONTCONFIG_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {fontconfig_ARGS:Mbuild}
# BUILD_DEPENDS+=	fontconfig:dev:standard
#.else
# BUILD_DEPENDS+=	fontconfig:dev:standard
# BUILDRUN_DEPENDS+=	fontconfig:primary:standard
#.endif
# -----------------------------------------------

.endif
