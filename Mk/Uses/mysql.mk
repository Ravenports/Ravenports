# handle dependency on MySQL databases (and derivatives)
#
# Feature:	mysql
# Usage:	USES=mysql
# Valid ARGS:	none (client)
#               server (implies client)
#               client
#		build (sets to build depends only; buildrun is default)
#
# Set BROKEN_MYSQL=<list> if the port specifically
# does not support one or more of the 12 or so MySQL derivatives

.if !defined(_INCLUDE_USES_POSTGRESQL_MK)
_INCLUDE_USES_POSTGRESQL_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------

# Detected MySQL version (read-only)
MYSQL_VER=	${MYSQL_${MYSQL_DEFAULT}_VERSION}

.endif
