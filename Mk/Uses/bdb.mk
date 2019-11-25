# Provide support for Berkeley DB
#
# Feature:	bdb
# Usage:	bdb[:version]
# Valid ARGS:	none (implies 5), 5, 6, 18, static
#
# This module sets the following variables:
# BDB_LIB_NAME     - Set to the name of the Berkeley DB library
# BDB_LIB_CXX_NAME - Set to the name of the Berkeley DB C++ library
# BDB_INCLUDE_DIR  - Set to the location of the Berkeley DB include directory
# BDB_LIB_DIR      - Set to the location of the BDB library directory
# BDB_VER          - Berkeley DB version
#
# BUILDRUN_DEPENDS - set by ravenadm based on ARGS and "static" in not an ARG
# BUILD_DEPENDS    - set by ravenadm based on ARGS when "static" is an ARG
#
# The "argument" brings in only the static version of the bdb library.
#

.if !defined(_INCLUDE_USES_BDB_MK)
_INCLUDE_USES_BDB_MK=	yes

.  if ${bdb_ARGS} == "6"
BDB_VER=		6
BDB_LIB_NAME=		db-6.2
BDB_LIB_CXX_NAME=	db_cxx-6.2
.  elif ${bdb_ARGS} == "18"
BDB_VER=		18
BDB_LIB_NAME=		db-18.1
BDB_LIB_CXX_NAME=	db_cxx-18.1
.  else
BDB_VER=		5
BDB_LIB_NAME=		db-5.3
BDB_LIB_CXX_NAME=	db_cxx-5.3
.  endif
BDB_LIB_DIR=		${LOCALBASE}/lib/db${BDB_VER}
BDB_INCLUDE_DIR=	${LOCALBASE}/include/db${BDB_VER}

LDFLAGS+=		-L${BDB_LIB_DIR} -lpthread
CPPFLAGS+=		-I${BDB_INCLUDE_DIR}
CFLAGS+=		-I${BDB_INCLUDE_DIR}

.endif	# defined(_INCLUDE_USES_BDB_MK)
