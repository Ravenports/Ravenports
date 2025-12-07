# Provide support for CMake based projects
#
# Feature:		cmake
# Usage:		USES=cmake or USES=cmake:ARGS
# Valid ARGS:		insource, run
#
# ARGS description:
# insource		do not perform an out-of-source build
# run			set as BUILDRUNS instead of BUILD dependency
#
# Additional ports variables that affect cmake behaviour:
# CMAKE_ARGS	      - Arguments passed to cmake
#			Default: see below
# CMAKE_BUILD_TYPE    - Type of build (cmake predefined build types).
#			Projects may have their own build profiles.
#			CMake supports the following types: Debug,
#			Release, RelWithDebInfo and MinSizeRel.
#			Debug and Release profiles respect system
#			CFLAGS, RelWithDebInfo and MinSizeRel will set
#			CFLAGS to "-O2 -g" and "-Os -DNDEBUG".
#			Default: Release, if WITH_DEBUG is not set,
#			Debug otherwise
# CMAKE_SOURCE_PATH   - Path to the source directory
#			Default: ${WRKSRC}
#
# BELOW IS NOT SUPPORTED (But maybe it should be)
# CMAKE_MORE_MODULES  - Add non-standard paths to search for modules
#			This is how to update CMAKE_MODULE_PATH

.if !defined(_INCLUDE_USES_CMAKE_MK)
_INCLUDE_USES_CMAKE_MK=	yes

CMAKE_BIN=		${LOCALBASE}/bin/cmake

.  if defined(WITH_DEBUG)
CMAKE_BUILD_TYPE?=	Debug
.  else
CMAKE_BUILD_TYPE?=	Release
.  endif

PLIST_SUB+=		CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:tl}"

.  if !defined(WITH_DEBUG)
INSTALL_TARGET?=	install/strip
.  endif

CMAKE_ARGS+=		-DCMAKE_C_COMPILER:STRING="${CC}" \
			-DCMAKE_CXX_COMPILER:STRING="${CXX}" \
			-DCMAKE_C_FLAGS:STRING="${CFLAGS}" \
			-DCMAKE_C_FLAGS_DEBUG:STRING="${CFLAGS}" \
			-DCMAKE_C_FLAGS_RELEASE:STRING="${CFLAGS}" \
			-DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS}" \
			-DCMAKE_CXX_FLAGS_DEBUG:STRING="${CXXFLAGS}" \
			-DCMAKE_CXX_FLAGS_RELEASE:STRING="${CXXFLAGS}" \
			-DCMAKE_EXE_LINKER_FLAGS:STRING="${LDFLAGS}" \
			-DCMAKE_MODULE_LINKER_FLAGS:STRING="${LDFLAGS}" \
			-DCMAKE_SHARED_LINKER_FLAGS:STRING="${LDFLAGS}" \
			-DCMAKE_INSTALL_PREFIX:PATH="${CMAKE_INSTALL_PREFIX}" \
			-DCMAKE_INSTALL_MANDIR:PATH="${MANPREFIX}/man" \
			-DCMAKE_INSTALL_DOCDIR:PATH="share/doc/${NAMEBASE}" \
			-DCMAKE_INSTALL_LIBDIR:STRING="lib" \
			-DCMAKE_BUILD_TYPE:STRING="${CMAKE_BUILD_TYPE}" \
			-DTHREADS_HAVE_PTHREAD_ARG:BOOL=YES \
			-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=YES

. if empty(USES:Mninja)
CMAKE_ARGS+=		-DCMAKE_COLOR_MAKEFILE:BOOL=OFF -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
.  endif

CMAKE_INSTALL_PREFIX?=	${PREFIX}

_CMAKE_MSG=		"===>  Performing in-source build"
CMAKE_SOURCE_PATH?=	${WRKSRC}

.  if empty(cmake_ARGS:Minsource)
_CMAKE_MSG=		"===>  Performing out-of-source build"
CONFIGURE_WRKSRC=	${WRKDIR}/.build
BUILD_WRKSRC?=		${CONFIGURE_WRKSRC}
INSTALL_WRKSRC?=	${CONFIGURE_WRKSRC}
TEST_WRKSRC?=		${CONFIGURE_WRKSRC}
.  endif

.  if !target(do-configure)
do-configure:
	@${ECHO_MSG} ${_CMAKE_MSG}
	${MKDIR} ${CONFIGURE_WRKSRC}
	@${ECHO_MSG} "============================================="
	@${ECHO_MSG} "    ${SETENV} ${CONFIGURE_ENV}"
	@${ECHO_MSG} "    ${CMAKE_BIN} ${CMAKE_ARGS} ${CMAKE_SOURCE_PATH}"
	@${ECHO_MSG} "============================================="
	@(cd ${CONFIGURE_WRKSRC} && ${SETENV} ${CONFIGURE_ENV} \
		${CMAKE_BIN} ${CMAKE_ARGS} ${CMAKE_SOURCE_PATH})
.  endif

.endif	# !defined(_INCLUDE_USES_CMAKE_MK)
