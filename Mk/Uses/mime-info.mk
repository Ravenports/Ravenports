# handle dependency on shared-mime-info package
#
# Feature:	mime-info
# Usage:	USES=mime-info
# Valid ARGS:	name of subpackage

.if !defined(_INCLUDE_USES_MIMEINFO_MK)
_INCLUDE_USES_MIMEINFO_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILDRUN_DEPENDS+=	shared-mime-info:primary:standard
# -----------------------------------------------

_USES_stage+=	936:add-plist-mimeinfo

.  if !target(add-plist-mimeinfo)
add-plist-mimeinfo:
	@if [ -f "${WRKDIR}/.manifest.${mime-info_ARGS}.mktmp" ]; then \
	  echo "@shared-mime-info share/mime" >> ${WRKDIR}/.manifest.${mime-info_ARGS}.mktmp; \
	fi
.  endif

.endif
