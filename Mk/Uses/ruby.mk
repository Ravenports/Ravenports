# Handle dependency requirements on ruby
#
# Feature:	ruby
# Usage:	USES=ruby
# Valid ARGS:	(v23 or v24), build, interp
#
# --------------------------------------
# Variables which can be set by the port
# --------------------------------------
#
# RUBY_SETUP		- Set to the alternative name of setup.rb
#			  (default: setup.rb).
#
# --------------------------------------
# Readonly variables
# --------------------------------------
# RUBY_VER		- Set to the alternative short version of ruby in the
#			  form of `x.y' (see below for current value).
# RUBY_SUFFIX		- Suffix for ruby binaries and directories
# RUBY_ARCH		- Set to target architecture name.
# RUBY_SHLIBVER		- Major version of libruby (see below for current value)
# RUBY_LIBDIR		- Installation path for architecture independent libraries.
# RUBY_ARCHLIBDIR	- Installation path for architecture dependent libraries.
# RUBY_SITELIBDIR	- Installation path for site arch. independent libraries.
# RUBY_SITEARCHLIBDIR	- Installation path for site arch. dependent libraries.
# RUBY_DOCDIR		- Installation path for documents.
# RUBY_EXAMPLESDIR	- Installation path for examples.
# RUBY_RIDIR		- Installation path for site arch. independent ri documents.
# RUBY_SITERIDIR	- Installation path for site arch. dependent ri documents.
#

.if !defined(_INCLUDE_USES_RUBY_MK)
_INCLUDE_USES_RUBY_MK=	yes

# ------------------------------------------------------
# Incorporated in ravenadm
# ------------------------------------------------------
# BUILD/RUN_DEPENDS+=	rubyXX:single:standard
# ------------------------------------------------------

.  if !empty(ruby_ARGS:Mv24)
_RUBY_VERSION=	2.4
.  elif !empty(ruby_ARGS:Mv23)
_RUBY_VERSION=	2.3
.  else
_RUBY_VERSION=	${RUBY_DEFAULT}
.  endif

RUBY_VER=		${_RUBY_VERSION}
RUBY_SUFFIX=		${_RUBY_VERSION:S/.//g}
RUBY_SHLIBVER?=		${RUBY_VER:S/.//}

RUBY_NAME=		ruby${RUBY_SUFFIX}
RUBY_SYSLIBDIR=		${PREFIX}/lib
RUBY_SITEDIR=		${RUBY_SYSLIBDIR}/ruby/site_ruby
RUBY_VENDORDIR=		${RUBY_SYSLIBDIR}/ruby/vendor_ruby
RUBY_ARCH=		${ARCH_STANDARD}-${OPSYS:tl}${MAJOR}

# Directories
RUBY_LIBDIR?=		${RUBY_SYSLIBDIR}/ruby/${RUBY_VER}
RUBY_ARCHLIBDIR?=	${RUBY_LIBDIR}/${RUBY_ARCH}
RUBY_SITELIBDIR?=	${RUBY_SITEDIR}/${RUBY_VER}
RUBY_SITEARCHLIBDIR?=	${RUBY_SITELIBDIR}/${RUBY_ARCH}
RUBY_VENDORLIBDIR?=	${RUBY_VENDORDIR}/${RUBY_VER}
RUBY_VENDORARCHLIBDIR?=	${RUBY_VENDORLIBDIR}/${RUBY_ARCH}
RUBY_DOCDIR?=		${PREFIX}/share/doc/${RUBY_NAME}
RUBY_EXAMPLESDIR?=	${PREFIX}/share/examples/${RUBY_NAME}
RUBY_RIDIR?=		${PREFIX}/share/ri/${RUBY_VER}/system
RUBY_SITERIDIR?=	${PREFIX}/share/ri/${RUBY_VER}/site

# PLIST
PLIST_RUBY_DIRS=	RUBY_LIBDIR="${RUBY_LIBDIR}" \
			RUBY_ARCHLIBDIR="${RUBY_ARCHLIBDIR}" \
			RUBY_SITELIBDIR="${RUBY_SITELIBDIR}" \
			RUBY_SITEARCHLIBDIR="${RUBY_SITEARCHLIBDIR}" \
			RUBY_VENDORLIBDIR="${RUBY_VENDORLIBDIR}" \
			RUBY_VENDORARCHLIBDIR="${RUBY_VENDORARCHLIBDIR}" \
			RUBY_DOCDIR="${RUBY_DOCDIR}" \
			RUBY_EXAMPLESDIR="${RUBY_EXAMPLESDIR}" \
			RUBY_RIDIR="${RUBY_RIDIR}" \
			RUBY_SITERIDIR="${RUBY_SITERIDIR}"

PLIST_SUB+=		${PLIST_RUBY_DIRS:C,DIR="(${LOCALBASE}|${PREFIX})/,DIR=",} \
			RUBY_VERSION="${RUBY_VERSION}" \
			RUBY_VER="${RUBY_VER}" \
			RUBY_SHLIBVER="${RUBY_SHLIBVER}" \
			RUBY_ARCH="${RUBY_ARCH}" \
			RUBY_SUFFIX="${RUBY_SUFFIX}" \
			RUBY_NAME="${RUBY_NAME}" \

RUBY_CONFIGURE_ARGS+=	--with-rubyhdrdir="${PREFIX}/include/ruby-${RUBY_VER}/" \
			--with-rubylibprefix="${PREFIX}/lib/ruby" \
			--docdir="${RUBY_DOCDIR}" \
			--with-soname=ruby${RUBY_SUFFIX} \
			--program-prefix="" \
			--program-suffix="${RUBY_SUFFIX}"

.endif	# _INCLUDE_USES_RUBY_MK
