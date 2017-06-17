# Provide support to use Ninja
#
# Feature:		ninja
# Usage:		USES=ninja
#
# Ravenadm sets ninja:single:standard
#

.if !defined(_INCLUDE_USES_NINJA_MK)
_INCLUDE_USES_NINJA_MK=	yes

MAKE_ARGS+=		-v
CMAKE_ARGS+=		-GNinja
MAKE_CMD=		ninja
DESTDIR_VIA_ENV=	yes
MAKE_FLAGS=
MAKEFILE=

.endif
