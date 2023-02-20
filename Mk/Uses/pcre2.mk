# handle dependency on PCRE2
#
# Feature:	pcre2
# Usage:	USES=pcre2 or USES=pcre2:ARGS
# Valid ARGS:	buildrun (implicit), build
#

.if !defined(_INCLUDE_USES_ZSTD_MK)
_INCLUDE_USES_ZSTD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${pcre2_ARGS:Mbuild}
# BUILD_DEPENDS+=	pcre2:dev:standard
#.else
# BUILD_DEPENDS+=	pcre2:dev:standard
# BUILDRUN_DEPENDS+=	pcre2:primary:standard
#.endif
# -----------------------------------------------

.endif
