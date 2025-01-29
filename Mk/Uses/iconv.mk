# handle dependency on the libiconv port
#
# Feature:	iconv
# Usage:	USES=iconv or USES=iconv:ARGS
# Valid ARGS:	buildrun (default, implicit), build, standalone
#
# Libiconv is not added to systems with iconv supported by glibc
# unless "standalone" argument is set.

.if !defined(_INCLUDE_USES_ICONV_MK)
_INCLUDE_USES_ICONV_MK=	yes


.  if !exists(/usr/include/libintl.h) || ${iconv_ARGS:Mstandalone}

ICONV_CMD=		${LOCALBASE}/bin/iconv
ICONV_LIB=		-liconv
ICONV_PREFIX=		${LOCALBASE}
ICONV_CONFIGURE_ARG=	--with-libiconv-prefix=${LOCALBASE}
ICONV_CONFIGURE_BASE=	--with-libiconv=${LOCALBASE}
ICONV_INCLUDE_PATH=	${LOCALBASE}/include
ICONV_LIBRARY_PATH=	${LOCALBASE}/lib
ICONV_LIBRARY=		${LOCALBASE}/lib/libiconv.so

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

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${iconv_ARGS:Mbuild}
# BUILD_DEPENDS+=	libiconv:dev:std
#.else
# BUILD_DEPENDS+=	libiconv:dev:std
# BUILDRUN_DEPENDS+=	libiconv:primary:std
#.endif
# -----------------------------------------------


.  else

ICONV_CMD=		/usr/bin/iconv
ICONV_LIB=
ICONV_PREFIX=		/usr
ICONV_CONFIGURE_ARG=
ICONV_CONFIGURE_BASE=
ICONV_INCLUDE_PATH=	/usr/include
ICONV_LIBRARY_PATH=	/usr/lib
ICONV_LIBRARY=

.  endif

.endif
