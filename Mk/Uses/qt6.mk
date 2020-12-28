# Common build specifications for Qt6 framework
#
# Feature:	qt6
# Usage:	USES=qt6
# Valid ARGS:	none
#

.if !defined(_INCLUDE_USES_QT6_MK)
_INCLUDE_USES_QT6_MK=	yes

# stage support
# DESTDIRNAME=	INSTALL_ROOT

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

BASE_CONF_ARGS=\
	-opensource\
	-confirm-license\
	-no-pch\
	-platform ${QMAKESPEC}\
	-prefix      "${PREFIX}"\
	-libdir      "${PREFIX}/lib/qt6"\
	-bindir      "${PREFIX}/lib/qt6/bin"\
	-plugindir   "${PREFIX}/lib/qt6/plugins"\
	-qmldir      "${PREFIX}/lib/qt6/qml"\
	-archdatadir "${PREFIX}/lib/qt6"\
	-libexecdir  "${PREFIX}/libexec/qt6"\
	-headerdir   "${PREFIX}/include/qt6"\
	-datadir     "${PREFIX}/share/qt6"\
	-sysconfdir  "${PREFIX}/etc/xdg"\
	-docdir      "${PREFIX}/share/doc/qt6"\
	-examplesdir "${PREFIX}/share/examples/${NAMEBASE}"\
	-testsdir    "${PREFIX}/share/qt6/tests"\
	-translationdir "${PREFIX}/share/qt6/translations"\
	-nomake examples\
	-nomake tests

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

. else

QMAKESPEC=	unsupported-OS

. endif

. if "${NAMEBASE}" == "qt6-qtbase"
HAS_CONFIGURE=		yes
# CONFIGURE_ARGS+=	${BASE_CONF_ARGS}
CMAKE_ARGS+=		${BASE_CMAKE_ARGS}
. else
.  if !defined(GNU_CONFIGURE)
.   if !target(do-configure)
do-configure:
	(cd ${WRKSRC} && ${QMAKE_CMD} ${QMAKE_ARGS} -o Makefile)
.   endif
.  endif
. endif

.endif		# _INCLUDE_USES_QT6_MK
