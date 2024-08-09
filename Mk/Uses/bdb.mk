# Provide support for Berkeley DB
#
# Feature:	bdb
# Usage:	bdb[:version]
# Valid ARGS:	none (implies 5), 5, 18, buildrun (implicit), build
#
# This module sets the following variables:
# BDB_LIB_NAME     - Set to the name of the Berkeley DB library
# BDB_LIB_CXX_NAME - Set to the name of the Berkeley DB C++ library
# BDB_INCLUDE_DIR  - Set to the location of the Berkeley DB include directory
# BDB_LIB_DIR      - Set to the location of the BDB library directory
# BDB_VER          - Berkeley DB version
#

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${bdb_ARGS:Mbuild}
# BUILD_DEPENDS+=	db{X}:dev:std
#.else
# BUILD_DEPENDS+=	db{X}:dev:std
# BUILDRUN_DEPENDS+=	db{X}:primary:std
#.endif
# -----------------------------------------------


.if !defined(_INCLUDE_USES_BDB_MK)
_INCLUDE_USES_BDB_MK=	yes

.  if ${bdb_ARGS} == "18"
BDB_VER=		18
BDB_LIB_NAME=		db
BDB_LIB_CXX_NAME=	db_cxx
.  else
BDB_VER=		5
BDB_LIB_NAME=		db
BDB_LIB_CXX_NAME=	db_cxx
.  endif
BDB_LIB_DIR=		${LOCALBASE}/db${BDB_VER}/lib
BDB_INCLUDE_DIR=	${LOCALBASE}/db${BDB_VER}/include

LDFLAGS+=		-L${BDB_LIB_DIR} -lpthread
CPPFLAGS+=		-I${BDB_INCLUDE_DIR}
CFLAGS+=		-I${BDB_INCLUDE_DIR}

.endif	# defined(_INCLUDE_USES_BDB_MK)
