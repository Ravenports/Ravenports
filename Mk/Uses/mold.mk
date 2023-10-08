# Adds linker flag to switch to Mold linker and pull in the mold package
#
# Feature:      mold
# Usage:        USES=mold
# Valid ARGS:   none

.if !defined(_INCLUDE_USES_MOLD_MK)
_INCLUDE_USES_MOLD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	mold:primary:standard
# -----------------------------------------------

LDFLAGS+=	-fuse-ld=mold

.endif  # _INCLUDE_USES_MOLD_MK
