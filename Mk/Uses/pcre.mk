# handle dependency on pcre
#
# Feature:	pcre
# Usage:	USES=pcre or USES=pcre:ARGS
# Valid ARGS:	buildrun (default, implicit), build
#

.if !defined(_INCLUDE_USES_PCRE_MK)
_INCLUDE_USES_PCRE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {pcre_ARGS:Mbuild}
# BUILD_DEPENDS+=	pcre:static:standard
#.else
# BUILD_DEPENDS+=	pcre:static:standard
# BUILDRUN_DEPENDS+=	pcre:shared:standard
#.endif
# -----------------------------------------------

.endif
