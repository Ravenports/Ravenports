# Provide support to use Ninja
#
# Feature:		ninja
# Usage:		USES=ninja
#
# ------------------------------------------------------
# Incorporated in ravenadm
# ------------------------------------------------------
# BUILD_DEPENDS+=   ninja:single:python_used
# ------------------------------------------------------

.if !defined(_INCLUDE_USES_NINJA_MK)
_INCLUDE_USES_NINJA_MK=	yes

MAKE_ARGS+=		-v -d explain
CMAKE_ARGS+=		-GNinja
MAKE_CMD=		ninja
DESTDIR_VIA_ENV=	yes
MAKE_FLAGS=
MAKEFILE=

.endif
