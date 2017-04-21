# Handle dependency requirement on gprbuild
#
# Feature:	gprbuild
# Usage:	USES=gprbuild
# Valid ARGS:	build (default, implicit), run, buildrun
#

.if !defined(_INCLUDE_USES_GPRBUILD_MK)
_INCLUDE_USES_GPRBUILD_MK=	yes

# The logic is contained in ravenadm.
# The presence of USES=gprbuild turns it on.
# gprbuild:primary:standard

.endif
