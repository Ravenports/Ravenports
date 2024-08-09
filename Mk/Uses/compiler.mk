# Handle runtime requirement on the complete GNU compiler compiler
#
# Feature:	compiler
# Usage:	USES=compiler
# Valid ARGS:	none
#

.if !defined(_INCLUDE_USES_COMPILER_MK)
_INCLUDE_USES_COMPILER_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# EXRUN[subpackage]=	ravensys-gcc:set:std
# -----------------------------------------------

.endif
