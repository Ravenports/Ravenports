# Handle dependency on the ncurses port
#
# Feature:	ncurses
# Usage:	USES=ncurses
# Valid ARGS:	none or "static"
#
# Port makefile can now set this variable
# NCURSES_RPATH= defined	- pass RFLAGS options to CFLAGS
#
# The makefile sets the following variables:
# NCURSESBASE		- ${LOCALBASE}
# NCURSESLIB		- path to the libs
# NCURSESINC		- path to the matching includes
# NCURSESRPATH		- rpath for dynamic linker
#
# BUILDRUN_DEPENDS	- are added by ravenadm (version based on ARGS)
#

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
