# handle dependency on the makeinfo port
#
# Feature:	makeinfo
# Usage:	USES=makeinfo
# Valid ARGS:	none
#

.if !defined(_INCLUDE_USES_MAKEINFO_MK)
_INCLUDE_USES_MAKEINFO_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	texinfo:single:standard
# -----------------------------------------------

.endif
