# Directs linker selector to use the bfd linker in the toolchain
# This does not set -fuse-ld linker flags.
# Ignored for Solaris platforms which do not have linker selector.
#
# Feature:      gold
# Usage:        USES=bfd
# Valid ARGS:   none

.if !defined(_INCLUDE_USES_BFD_MK)
_INCLUDE_USES_BFD_MK=	yes

.  if "${OPSYS}" != "SunOS"
CONFIGURE_ENV+=	LINKER=bfd
MAKE_ENV+=	LINKER=bfd
.  endif

.endif  # _INCLUDE_USES_BFD_MK
