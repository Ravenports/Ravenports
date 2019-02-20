# Handle dependency on the selected SSL library
# SSL_VARIANT is always defined in the environment.
# SSL_VARIANT is defined as the SSL default of the ravenadm
# profile unless the valid ARGS overrides it.
#
# Feature:	Implement default SSL version
# Usage:	USES=ssl
# Valid ARGS:	buildrun (default), build, run
#               openssl, libressl, openssl-devel, libressl-devel
#
# Port makefile can now set these variable
# OPENSSL_RPATH=yes	- pass RFLAGS options to CFLAGS
#
# The makefile sets the following variables:
# OPENSSLBASE		- ${LOCALBASE}
# OPENSSLCERT		- path to openssl certs
# OPENSSLLIB		- path to the libs
# OPENSSLINC		- path to the matching includes
# OPENSSLRPATH		- rpath for dynamic linker
#
# Ravenadm handles BUILD_*, RUN_*, and BUILDRUN_* depends as needed

.if !defined(_INCLUDE_USES_SSL_MK)
_INCLUDE_USES_SSL_MK=	yes

OPENSSLBASE=	${LOCALBASE}/${SSL_VARIANT}
OPENSSLCERT=	${LOCALBASE}/etc/${SSL_VARIANT}
OPENSSLLIB=	${OPENSSLBASE}/lib
OPENSSLINC=	${OPENSSLBASE}/include
OPENSSLRPATH=	${OPENSSLLIB}
OPENSSLPC=	${OPENSSLLIB}/pkgconfig

CPPFLAGS+=	-I${OPENSSLINC}
CFLAGS+=	-I${OPENSSLINC}

.  if defined(OPENSSL_RPATH)
CFLAGS+=	-Wl,-rpath,${OPENSSLRPATH}
.  else
LDFLAGS+=	-L${OPENSSLRPATH}
LDFLAGS+=	-Wl,-rpath,${OPENSSLRPATH}
MAKE_ENV+=	OPENSSLRPATH=${OPENSSLRPATH}
.  endif

MAKE_ENV+=	OPENSSLBASE=${OPENSSLBASE} \
		OPENSSLCERT=${OPENSSLCERT} \
		OPENSSLINC=${OPENSSLINC} \
		OPENSSLLIB=${OPENSSLLIB} \
		PKG_CONFIG_PATH=${OPENSSLPC}
CONFIGURE_ENV+=	PKG_CONFIG_PATH=${OPENSSLPC}

# for cargo support (only in effect with USES=cargo)
CARGO_ENV+=	OPENSSL_LIB_DIR=${OPENSSLLIB} \
		OPENSSL_INCLUDE_DIR=${OPENSSLINC}

.endif
