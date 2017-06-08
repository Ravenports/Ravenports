# handle dependency on mesa
#
# Feature:	mesa
# Usage:	USES=mesa
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_MESA_MK)
_INCLUDE_USES_MESA_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	mesa:libs:standard
# -----------------------------------------------

.endif
