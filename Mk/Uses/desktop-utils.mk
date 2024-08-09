# Handles dependency on desktop-file-utils and updates subpackage
# packaging list
#
# Feature:	desktop-utils
# Usage:	USES=desktop-utils
# Valid ARGS:	subpackage
#
# ravenadm add desktop-file-utils:primary:std to BUILDRUN_DEPENDS
#

.if !defined(_INCLUDE_USES_DESKTOP_UTILS_MK)
_INCLUDE_USES_DESKTOP_UTILS_MK=	yes

.endif	# _INCLUDE_USES_DESKTOP_UTILS_MK
