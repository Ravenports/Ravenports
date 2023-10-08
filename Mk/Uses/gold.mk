# Adds linker flag to switch to Gold linker
#
# Feature:      gold
# Usage:        USES=gold
# Valid ARGS:   none

.if !defined(_INCLUDE_USES_GOLD_MK)
_INCLUDE_USES_GOLD_MK=	yes

LDFLAGS+=	-fuse-ld=gold

.endif  # _INCLUDE_USES_GOLD_MK
