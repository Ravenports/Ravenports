# Common build specifications for Qt5 framework
#
# Feature:	qt5
# Usage:	USES=qt5
# Valid ARGS:	none
#

.if !defined(_INCLUDE_USES_QT5_MK)
_INCLUDE_USES_QT5_MK=	yes

# stage support
DESTDIRNAME=	INSTALL_ROOT

# When configure used, set common switches
BASE_CONF_ARGS=\
	-opensource\
	-confirm-license\
	-no-pch\
	-platform ${QMAKESPEC}\
	-prefix      "${PREFIX}"\
	-libdir      "${PREFIX}/lib/qt5"\
	-bindir      "${PREFIX}/lib/qt5/bin"\
	-plugindir   "${PREFIX}/lib/qt5/plugins"\
	-importdir   "${PREFIX}/lib/qt5/imports"\
	-qmldir      "${PREFIX}/lib/qt5/qml"\
	-archdatadir "${PREFIX}/lib/qt5"\
	-libexecdir  "${PREFIX}/libexec/qt5"\
	-headerdir   "${PREFIX}/include/qt5"\
	-datadir     "${PREFIX}/share/qt5"\
	-sysconfdir  "${PREFIX}/etc/xdg"\
	-docdir      "${PREFIX}/share/doc/qt5"\
	-examplesdir "${PREFIX}/share/examples/${NAMEBASE}"\
	-testsdir    "${PREFIX}/share/qt5/tests"\
	-translationdir "${PREFIX}/share/qt5/translations"\
	-nomake examples\
	-nomake tests

QMAKE_CMD=		${LOCALBASE}/lib/qt5/bin/qmake

. if defined(WITH_DEBUG)
BASE_CONF_ARGS+=	-debug -separate-debug-info
. else
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

. if "${NAMEBASE}" == "qt5-qtbase"
HAS_CONFIGURE=		yes
CONFIGURE_ARGS+=	${BASE_CONF_ARGS}
. else
.  if !defined(GNU_CONFIGURE)
.   if !target(do-configure)
do-configure:
	(cd ${WRKSRC} && ${QMAKE_CMD} ${QMAKE_ARGS} -o Makefile)
.   endif
.  endif
. endif

.endif		# _INCLUDE_USES_QT5_MK
