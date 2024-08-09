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
# RUN_DEPENDS+=	shared-mime-info:primary:std
# -----------------------------------------------

.endif
