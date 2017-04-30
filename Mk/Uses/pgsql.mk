# handle dependency on PostgreSQL databases
#
# Feature:	pgsql
# Usage:	USES=pgsql
# Valid ARGS:	none (implies client+buildrun)
#               server (implies client)
#               client
#               plperl
#               plpython
#               pltcl
#               contrib
#               all
#               build (sets to build depends only; buildrun is default)
#
# Set BROKEN_PGSQL=<list> if the port specifically
# does not support one or more of the postgresql derivatives


.if !defined(_INCLUDE_USES_POSTGRESQL_MK)
_INCLUDE_USES_POSTGRESQL_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------

# Detected MySQL version (read-only)
PGSQL_VER=	${PGSQL_${MYSQL_DEFAULT}_VERSION}

.endif
