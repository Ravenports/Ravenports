# Handle special requirements of C++ runtime libraries
#
# Feature:	c++
# Usage:	USES=c++
# Valid ARGS:	subpackage (at least one required)
#

.if !defined(_INCLUDE_USES_CXX_MK)
_INCLUDE_USES_CXX_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# EXRUN[subpackage]=	ravensys-gcc:cxx_run:std
# -----------------------------------------------

.endif
