# handle dependency on the readline library
#
# Feature:	readline
# Usage:	USES=readline
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_READLINE_MK)
_INCLUDE_USES_READLINE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	readline:single:standard
# -----------------------------------------------

.endif
