# Handle dependency on the selected SSL library
#
# Feature:	Implement default SSL version
# Usage:	USES=ssl
# Valid ARGS:	buildrun (default), build, run
#
# Port makefile can now set these variable
# OPENSSL_RPATH=yes	- pass RFLAGS options to CFLAGS
#
# The makefile sets the following variables:
# OPENSSLBASE		- ${LOCALBASE}
# OPENSSLDIR		- path to openssl certs
# OPENSSLLIB		- path to the libs
# OPENSSLINC		- path to the matching includes
# OPENSSLRPATH		- rpath for dynamic linker
#
# Ravenadm handles BUILD_*, RUN_*, and BUILDRUN_* depends as needed

.if !defined(_INCLUDE_USES_SSL_MK)
_INCLUDE_USES_SSL_MK=	yes

OPENSSLBASE=	${LOCALBASE}
OPENSSLDIR=	${OPENSSLBASE}/openssl
OPENSSLLIB=	${OPENSSLBASE}/lib
OPENSSLINC=	${OPENSSLBASE}/include
OPENSSLRPATH=	${OPENSSLLIB}

.  if defined(OPENSSL_RPATH)
CFLAGS+=	-Wl,-rpath,${OPENSSLRPATH}
.  else
# rpath already set to this value
# LDFLAGS+=	-Wl,-rpath=${OPENSSLRPATH}
MAKE_ENV+=	OPENSSLRPATH=${OPENSSLRPATH}
.  endif

MAKE_ENV+=	OPENSSLBASE=${OPENSSLBASE} \
		OPENSSLDIR=${OPENSSLDIR} \
		OPENSSLINC=${OPENSSLINC} \
		OPENSSLLIB=${OPENSSLLIB}

# for cargo support (only in effect with USES=cargo)
CARGO_ENV+=	OPENSSL_LIB_DIR=${OPENSSLLIB} \
		OPENSSL_INCLUDE_DIR=${OPENSSLINC}

.endif
