# Provide support to use the GNU make
#
# Feature:		gmake
# Usage:		USES=gmake
# Arguments:		none
#

.if !defined(_INCLUDE_USES_GMAKE_MK)
_INCLUDE_USES_GMAKE_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	gmake:single:standard
# -----------------------------------------------
CONFIGURE_ENV+=		MAKE=gmake
MAKE_CMD=		gmake

.endif
