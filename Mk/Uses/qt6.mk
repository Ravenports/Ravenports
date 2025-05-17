# Common build specifications for Qt6 framework
#
# Feature:	qt6
# Usage:	USES=qt6
# Valid ARGS:	none
#

.if !defined(_INCLUDE_USES_QT6_MK)
_INCLUDE_USES_QT6_MK=	yes

# When configure used, set common switches
BASE_CMAKE_ARGS=\
	-DQT_QMAKE_TARGET_MKSPEC=${QMAKESPEC}\
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"\
	-DINSTALL_LIBDIR="${PREFIX}/lib/qt6"\
	-DINSTALL_BINDIR="${PREFIX}/lib/qt6/bin"\
	-DINSTALL_PLUGINSDIR="${PREFIX}/lib/qt6/plugins"\
	-DINSTALL_INCLUDEDIR="${PREFIX}/include/qt6"\
	-DINSTALL_DOCDIR="${PREFIX}/share/doc/qt6"\
	-DINSTALL_LIBEXECDIR="${PREFIX}/libexec/qt6"\
	-DINSTALL_DATADIR="${PREFIX}/share/qt6"\
	-DINSTALL_ARCHDATADIR="${PREFIX}/lib/qt6"\
	-DINSTALL_QMLDIR="${PREFIX}/lib/qt6/qml"\
	-DINSTALL_SYSCONFDIR="${PREFIX}/etc/xdg"\
	-DINSTALL_MKSPECSDIR="${PREFIX}/lib/qt6/mkspecs"

QMAKE_CMD=		${LOCALBASE}/lib/qt6/bin/qmake

. if defined(WITH_DEBUG)
BASE_CMAKE_ARGS+=	-DCMAKE_BUILD_TYPE=Debug \
			-DFEATURE_separate_debug_info=ON
BASE_CONF_ARGS+=	-debug -separate-debug-info
. else
BASE_CMAKE_ARGS+=	-DCMAKE_BUILD_TYPE=Release \
			-DFEATURE_separate_debug_info=OFF
BASE_CONF_ARGS+=	-release -no-separate-debug-info
. endif

. if "${OPSYS}" == "SunOS"

QMAKESPEC=		solaris-g++-64
QMAKE_LIBS_THREAD=	-lpthread -lrt
QMAKE_LFLAGS_THREAD=
QMAKE_X11_SYS_LIBS=	-lresolv -lsocket -lnsl

. elif "${OPSYS}" == "FreeBSD"

QMAKESPEC=		freebsd-g++
QMAKE_LIBS_THREAD=
QMAKE_LFLAGS_THREAD=	-pthread
QMAKE_X11_SYS_LIBS=	-lm

. elif "${OPSYS}" == "DragonFly"

QMAKESPEC=		dragonfly-g++
QMAKE_LIBS_THREAD=
QMAKE_LFLAGS_THREAD=	-pthread
QMAKE_X11_SYS_LIBS=	-lm

. elif "${OPSYS}" == "Linux"

QMAKESPEC=		linux-g++
QMAKE_LIBS_THREAD=	-lpthread
QMAKE_LFLAGS_THREAD=
QMAKE_X11_SYS_LIBS=	-lm

. elif "${OPSYS}" == "MidnightBSD"

QMAKESPEC=		midnightbsd-g++
QMAKE_LIBS_THREAD=
QMAKE_LFLAGS_THREAD=	-pthread
QMAKE_X11_SYS_LIBS=	-lm

. elif "${OPSYS}" == "NetBSD"

QMAKESPEC=		netbsd-g++
QMAKE_LIBS_THREAD=
QMAKE_LFLAGS_THREAD=	-pthread
QMAKE_X11_SYS_LIBS=	-lm

. else

QMAKESPEC=	unsupported-Ravenports-OS

. endif

. if "${NAMEBASE}" == "qt6-qtbase"
CMAKE_ARGS+=		${BASE_CMAKE_ARGS}
. elif ${NAMEBASE:Mqt6-qt*}
CMAKE_ARGS+=		-DCMAKE_PREFIX_PATH="${PREFIX}/lib/qt6/cmake"
CMAKE_ARGS+=		-DQT_QMAKE_TARGET_MKSPEC="${QMAKESPEC}"
_USES_install+=		730:strip-qt6
. else
# stage support

.  if empty(USES:Mcmake)
DESTDIRNAME=	INSTALL_ROOT

.   if !defined(GNU_CONFIGURE)
.    if !target(do-configure)
do-configure:
	(cd ${WRKSRC} && ${QMAKE_CMD} ${QMAKE_ARGS} -o Makefile)
.    endif
.   endif
.  endif
. endif

strip-qt6:
	${STRIP_CMD} ${STAGEDIR}${PREFIX}/lib/qt6/*.so ||:
	${STRIP_CMD} ${STAGEDIR}${PREFIX}/lib/qt6/plugins/*/*.so ||:

.endif		# _INCLUDE_USES_QT6_MK
