# Provide support to use scons build tool
#
# Feature:		scons
# Usage:		USES=scons
#

.if !defined(_INCLUDE_USES_SCONS_MK)
_INCLUDE_USES_SCONS_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	scons:single:standard
# -----------------------------------------------

MAKEFILE=		#
MAKE_FLAGS=		#
BUILD_TARGET=		#
CCFLAGS?=		${CFLAGS}
LINKFLAGS?=		${LDFLAGS}
LIBPATH?=		${LOCALBASE}/lib
CPPPATH?=		${LOCALBASE}/include
SCONS=			${LOCALBASE}/bin/scons
BUILD_DEPENDS+=		${SCONS}:devel/scons
MAKE_CMD=		${SCONS}
MAKE_ARGS+=		CCFLAGS="${CCFLAGS}" \
			CXXFLAGS="${CXXFLAGS}" \
			LINKFLAGS="${LINKFLAGS}" \
			CPPPATH="${CPPPATH}" \
			LIBPATH="${LIBPATH}" \
			PREFIX="${PREFIX}" \
			CC="${CC}" \
			CXX="${CXX}" \
			${DESTDIRNAME:tl}=${STAGEDIR}

.endif
