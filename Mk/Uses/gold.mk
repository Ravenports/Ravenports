# Directs linker selector to use the gold linker in the toolchain
# This does not set -fuse-ld linker flags.
# Ignored for Solaris platforms which do not have linker selector.
#
# Feature:      gold
# Usage:        USES=gold
# Valid ARGS:   none

.if !defined(_INCLUDE_USES_GOLD_MK)
_INCLUDE_USES_GOLD_MK=	yes

.  if "${OPSYS}" != "SunOS"
CONFIGURE_ENV+=	LINKER=gold
MAKE_ENV+=	LINKER=gold
.  endif

.endif  # _INCLUDE_USES_GOLD_MK
