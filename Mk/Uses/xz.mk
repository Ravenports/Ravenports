# handle dependency on XZ
#
# Feature:	xz
# Usage:	USES=xz or USES=xz:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_XZ_MK)
_INCLUDE_USES_XZ_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {xz_ARGS:Mbuild}
# BUILD_DEPENDS+=	xz:dev:std
#.else
# BUILD_DEPENDS+=	xz:dev:std
# BUILDRUN_DEPENDS+=	xz:primary:std
#.endif
# -----------------------------------------------

.endif
