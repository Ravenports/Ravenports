# handle dependency on SQLite (only version 3 available)
#
# Feature:	sqlite
# Usage:	USES=sqlite
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_SQLITE_MK)
_INCLUDE_USES_SQLITE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	sqlite:single:standard
# -----------------------------------------------

.endif
