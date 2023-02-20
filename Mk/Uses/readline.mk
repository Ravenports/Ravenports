# handle dependency on the readline library
#
# Feature:	readline
# Usage:	USES=readline
# Valid ARGS:	buildrun (implicit), build

.if !defined(_INCLUDE_USES_READLINE_MK)
_INCLUDE_USES_READLINE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${readline_ARGS:Mbuild}
# BUILD_DEPENDS+=	readline:dev:standard
#.else
# BUILD_DEPENDS+=	readline:dev:standard
# BUILDRUN_DEPENDS+=	readline:primary:standard
#.endif
# -----------------------------------------------

.endif
