# handle dependency on MySQL databases (and derivatives)
#
# Feature:	mysql
# Usage:	USES=mysql
# Valid ARGS:	none
#		server
#		build (sets to build depends only; buildrun is default)
#
# Set BROKEN_MYSQL=<list> if the port specifically
# does not support one or more of the MySQL derivatives

.if !defined(_INCLUDE_USES_POSTGRESQL_MK)
_INCLUDE_USES_POSTGRESQL_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# BUILD_DEPENDS+= <version>:dev:std
# if arguments contain "build":
#     BUILD_DEPENDS+= <version>:client:std
# else:
#     BUILDRUN_DEPENDS+= <version>:client:std
#
# if arguments contain "server":
#    if arguments contain "build":
#       BUILD_DEPENDS+= <version>:server:std
#    else:
#       BUILDRUN_DEPENDS+= <version>:client:std
# -----------------------------------------------

# Detected MySQL version (read-only)
MYSQL_VER=	${MYSQL_${MYSQL_DEFAULT}_VERSION}

.endif
