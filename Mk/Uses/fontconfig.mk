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
# BUILD_DEPENDS+=	fontconfig:dev:std
#.else
# BUILD_DEPENDS+=	fontconfig:dev:std
# BUILDRUN_DEPENDS+=	fontconfig:primary:std
#.endif
# -----------------------------------------------

.endif
