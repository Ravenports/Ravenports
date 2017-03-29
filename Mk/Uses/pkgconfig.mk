# handle dependency on the pkgconf port
#
# Feature:	pkgconfig
# Usage:	USES=pkgconfig or USES=pkgconfig:ARGS
# Valid ARGS:	build (default, implicit), run, buildrun

.if !defined(_INCLUDE_USES_PKGCONFIG_MK)
_INCLUDE_USES_PKGCONFIG_MK=	yes

# The logic is contained in ravenadm.
# The presence of USES=pkgconf turns it on.
# pkgconf:single:standard

.endif
