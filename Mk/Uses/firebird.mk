# handle dependency on the Firebird database
#
# Feature:	firebird
# Usage:	USES=firebird
# Valid ARGS:	none (client)
#               server (implies client)
#               client
#
# Set BROKEN_FIREBIRD=<list> if the port specifically
# does not support one (or more) of the options

.if !defined(_INCLUDE_USES_FIREBIRD_MK)
_INCLUDE_USES_FIREBIRD_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------

# Detected Firebird version (read-only)
FIREBIRD_VER=	${FIREBIRD_${FIREBIRD_DEFAULT}_VERSION}

.endif
