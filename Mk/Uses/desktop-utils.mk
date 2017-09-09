# Handles dependency on desktop-file-utils and updates subpackage
# packaging list
#
# Feature:	desktop-utils
# Usage:	USES=desktop-utils
# Valid ARGS:	subpackage
#
# ravenadm add desktop-file-utils:single:standard to RUN_DEPENDS
#

.if !defined(_INCLUDE_USES_DESKTOP_UTILS_MK)
_INCLUDE_USES_DESKTOP_UTILS_MK=	yes

_USES_stage+=	934:add-plist-desktop

.  if !target(add-plist-desktop)
add-plist-desktop:
	@if [ -f "${WRKDIR}/.manifest.${desktop-utils_ARGS}.mktmp" ]; then \
	  echo "@desktop-file-utils" >> ${WRKDIR}/.manifest.${desktop-utils_ARGS}.mktmp; \
	fi
.  endif

.endif	# _INCLUDE_USES_DESKTOP_UTILS_MK
