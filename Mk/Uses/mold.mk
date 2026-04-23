# Directs linker selector to use the mold linker from its package.
# This does not set -fuse-ld linker flags.
# Only affects Linux platform, the only one mold is built for.
#
# Feature:      mold
# Usage:        USES=mold
# Valid ARGS:   none

.if !defined(_INCLUDE_USES_MOLD_MK)
_INCLUDE_USES_MOLD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# If linux:
# BUILD_DEPENDS+=	mold:primary:std
# -----------------------------------------------

.  if "${OPSYS}" == "Linux"
CONFIGURE_ENV+=	LINKER=mold
MAKE_ENV+=	LINKER=mold
.  endif

.endif  # _INCLUDE_USES_MOLD_MK
