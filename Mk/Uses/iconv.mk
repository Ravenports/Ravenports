# handle dependency on the iconv port
#
# Feature:	iconv
# Usage:	USES=iconv or USES=iconv:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_ICONV_MK)
_INCLUDE_USES_ICONV_MK=	yes

ICONV_CMD=		${LOCALBASE}/bin/iconv
ICONV_LIB=		-liconv
ICONV_PREFIX=		${LOCALBASE}
ICONV_CONFIGURE_ARG=	--with-libiconv-prefix=${LOCALBASE}
ICONV_CONFIGURE_BASE=	--with-libiconv=${LOCALBASE}
ICONV_INCLUDE_PATH=	${LOCALBASE}/include
ICONV_LIBRARY_PATH=	${LOCALBASE}/lib
ICONV_LIBRARY=		${LOCALBASE}/lib/libiconv.so

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {iconv_ARGS:Mbuild}
# BUILD_DEPENDS+=	libiconv:static:standard
#.else
# BUILD_DEPENDS+=	libiconv:static:standard
# BUILDRUN_DEPENDS+=	libiconv:shared:standard
#.endif
# -----------------------------------------------

# These are the most common names for the iconv-related variables found in
# CMake-based ports. We set them here via CMAKE_ARGS to make sure that the
# best combination is always used (ie. we prefer the version in libc
# whenever it is available, and sometimes have to fall back to the iconv.h
# header from ports while still using the library from base).

CMAKE_ARGS+=	-DICONV_INCLUDE_DIR=${ICONV_INCLUDE_PATH} \
		-DICONV_LIBRARIES=${ICONV_LIBRARY} \
		-DICONV_LIBRARY=${ICONV_LIBRARY} \
		-DLIBICONV_INCLUDE_DIR=${ICONV_INCLUDE_PATH} \
		-DLIBICONV_LIBRARIES=${ICONV_LIBRARY} \
		-DLIBICONV_LIBRARY=${ICONV_LIBRARY}

.endif
