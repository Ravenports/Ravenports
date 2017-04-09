# Handle special requirements of Ada runtime libraries
#
# Feature:	ada
# Usage:	USES=ada
# Valid ARGS:	subpackage (at least one required)
#

.if !defined(_INCLUDE_USES_ADA_MK)
_INCLUDE_USES_ADA_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# EXRUN[subpackage]=	gcc6:ada_run:standard
# -----------------------------------------------

.endif
