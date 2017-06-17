# Feature:	display
# Usage:	USES=display or USES=display:ARGS
# Valid ARGS:	fetch, extract, patch, configure, build,
#               install (default, implicit), stage, test

.if !defined(_INCLUDE_USES_DISPLAY_MK)
_INCLUDE_USES_DISPLAY_MK=	yes

.  if empty(display_ARGS)
display_ARGS=	install
.  endif

# Ravenadm will set these BUILD_DEPENDS:
#   xorg-server:single:virtual
#   xorg-misc-bitmap-fonts:single:standard
#   xorg-font-alias:single:standard
#   daemonize:single:standard

.  if !defined(DISPLAY)

XVFBPORT=	0	# Guaranteed to be the only instance inside ravenadm
XVFBPIDFILE=	/tmp/.xvfb-${XVFBPORT}.pid
MAKE_ENV+=	DISPLAY=":${XVFBPORT}"
CONFIGURE_ENV+=	DISPLAY=":${XVFBPORT}"

.    for phase in ${display_ARGS}
_USES_${phase}+= 290:start-display 851:stop-display
.    endfor

start-display:
	daemonize -p ${XVFBPIDFILE} ${LOCALBASE}/bin/Xvfb :${XVFBPORT}

stop-display:
	cat ${XVFBPIDFILE} | xargs kill -15

.  endif
.endif
