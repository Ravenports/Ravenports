# Handle dependency on the ncurses port
#
# Feature:	ncurses
# Usage:	USES=ncurses
# Valid ARGS:	buildrun (default, implicit), build
#
# The makefile sets the following variables:
# NCURSESBASE		- ${LOCALBASE}
# NCURSESLIB		- path to the libs
# NCURSESINC		- path to the matching includes
#
# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=       ncurses:dev:std
# BUILDRUN_DEPENDS+=	ncurses:terminfo:std
#.if {ncurses_ARGS:Nbuild}
# BUILDRUN_DEPENDS+=	ncurses:primary:std
#.endif
# -----------------------------------------------

.if !defined(_INCLUDE_USES_NCURSES_MK)
_INCLUDE_USES_NCURSES_MK=	yes

NCURSESBASE=	${LOCALBASE}
NCURSESINC=	${NCURSESBASE}/include/ncurses
NCURSESLIB=	${NCURSESBASE}/lib

.  if defined(NCURSES_RPATH)
CFLAGS+=	-Wl,-rpath,${NCURSESLIB}
# rpath already set to this value
# .  else
# LDFLAGS+=	-Wl,-rpath=${NCURSESLIB}
.  endif
LDFLAGS+=	-lpthread

.endif
