# handle dependency on SQLite (only version 3 available)
#
# Feature:	sqlite
# Usage:	USES=sqlite
# Valid ARGS:	buildrun (implicit), build

.if !defined(_INCLUDE_USES_SQLITE_MK)
_INCLUDE_USES_SQLITE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${sqlite_ARGS:Mbuild}
# BUILD_DEPENDS+=	sqlite:dev:standard
#.else
# BUILD_DEPENDS+=	sqlite:dev:standard
# BUILDRUN_DEPENDS+=	sqlite:primary:standard
#.endif
# -----------------------------------------------

.endif
