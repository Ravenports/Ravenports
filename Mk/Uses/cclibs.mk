# Handle special requirements of GCC low-level and other libraries
#
# Feature:	cclibs
# Usage:	USES=cclibs
# Valid ARGS:	subpackage (at least one required)
#
# Use for one or more:
#   gcc_s   library
#   atomic  library
#   cc1     library
#   cilkrts libary
#   itm     library
#   ssp     library

.if !defined(_INCLUDE_USES_CCLIBS_MK)
_INCLUDE_USES_CCLIBS_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# EXRUN[subpackage]=	gcc6:libs:standard
# -----------------------------------------------

.endif
