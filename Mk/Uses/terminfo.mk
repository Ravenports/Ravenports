# handle terminfo.db and *.terminfo files used by ncurses
#
# Feature:	terminfo
# Usage:	USES=terminfo
# Valid ARGS:	name of subpackage

.if !defined(_INCLUDE_USES_TERMINFO_MK)
_INCLUDE_USES_TERMINFO_MK=	yes

_USES_stage+=	932:add-plist-terminfo

.  if !target(add-plist-terminfo)
add-plist-terminfo:
	@if [ -f "${WRKDIR}/.manifest.${terminfo_ARGS}.mktmp" ]; then \
	  echo "@terminfo" >> ${WRKDIR}/.manifest.${terminfo_ARGS}.mktmp; \
	fi
.  endif

.endif
