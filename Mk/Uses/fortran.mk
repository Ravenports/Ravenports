# Handle special requirements of Fortran runtime libraries
#
# Feature:	fortran
# Usage:	USES=fortran
# Valid ARGS:	subpackage (at least one required)
#

.if !defined(_INCLUDE_USES_FORTRAN_MK)
_INCLUDE_USES_FORTRAN_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# EXRUN[subpackage]=  gcc6:fortran_run:standard
# -----------------------------------------------

.endif
