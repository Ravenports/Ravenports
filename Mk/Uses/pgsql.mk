# handle dependency on PostgreSQL databases
#
# Feature:	pgsql
# Usage:	USES=pgsql
# Valid ARGS:	none (implies all+buildrun)
#               server (implies client)
#               client
#               plperl
#               plpython
#               pltcl
#               contrib
#               all
#               build (sets to build depends only; buildrun is default)

.if !defined(_INCLUDE_USES_POSTGRESQL_MK)
_INCLUDE_USES_POSTGRESQL_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------

.endif
