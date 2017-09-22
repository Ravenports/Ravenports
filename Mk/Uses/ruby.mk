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
# RUBY_EXTCONF		- Set to the alternative name of extconf.rb
#			  (default: extconf.rb)
# RUBY_FLAGS		- flags passed to ruby (default : blank)
#
# --------------------------------------
# Readonly variables
# --------------------------------------
# RUBY			- Set to full path of ruby
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
RUBY_VERSION=		${RUBY_${_RUBY_VERSION}_VERSION}
RUBY_SUFFIX=		${_RUBY_VERSION:S/.//g}
RUBY_SHLIBVER?=		${RUBY_VER:S/.//}
RUBY_SETUP?=		setup.rb
RUBY_EXTCONF?=		extconf.rb

RUBY_NAME=		ruby${RUBY_SUFFIX}
RUBY_SYSLIBDIR=		${PREFIX}/lib
RUBY_SITEDIR=		${RUBY_SYSLIBDIR}/ruby/site_ruby
RUBY_VENDORDIR=		${RUBY_SYSLIBDIR}/ruby/vendor_ruby
RUBY_ARCH=		${ARCH_STANDARD}-${OPSYS:tl}${MAJOR}
RUBY=			${LOCALBASE}/bin/${RUBY_NAME}

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

do-configure:	ruby-setup-configure ruby-extconf-configure
do-build:	ruby-setup-build
do-install:	ruby-setup-install

ruby-setup-configure:
.  if exists(${CONFIGURE_WRKSRC}/${RUBY_SETUP})
	@${ECHO_MSG} "===>  Running ${RUBY_SETUP} to configure"
	@(cd ${CONFIGURE_WRKSRC} && ${SETENV} ${CONFIGURE_ENV} \
		${RUBY} ${RUBY_FLAGS} ${RUBY_SETUP} config ${CONFIGURE_ARGS})
.  endif

ruby-extconf-configure:
.  if exists(${CONFIGURE_WRKSRC}/${RUBY_EXTCONF})
.    if defined(RUBY_EXTCONF_SUBDIRS)
.      for d in ${RUBY_EXTCONF_SUBDIRS}
	@${ECHO_MSG} "===>  Running ${RUBY_EXTCONF} in ${d} to configure"
	@(cd ${CONFIGURE_WRKSRC}/${d} && \
		${SETENV} ${CONFIGURE_ENV} RB_USER_INSTALL=yes \
		${RUBY} ${RUBY_FLAGS} ${RUBY_EXTCONF} \
		--with-opt-dir="${LOCALBASE}" ${CONFIGURE_ARGS})
.      endfor
.    else
	@${ECHO_MSG} "===>  Running ${RUBY_EXTCONF} to configure"
	@(cd ${CONFIGURE_WRKSRC} && \
		${SETENV} ${CONFIGURE_ENV} RB_USER_INSTALL=yes \
		${RUBY} ${RUBY_FLAGS} ${RUBY_EXTCONF} \
		--with-opt-dir="${LOCALBASE}" ${CONFIGURE_ARGS})
.    endif
.  endif

ruby-setup-build:
.  if exists(${BUILD_WRKSRC}/${RUBY_SETUP})
	@${ECHO_MSG} "===>  Running ${RUBY_SETUP} to build"
	@(cd ${BUILD_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} ${RUBY_FLAGS} ${RUBY_SETUP} setup)
.  endif

ruby-setup-install:
.  if exists(${INSTALL_WRKSRC}/${RUBY_SETUP})
	@${ECHO_MSG} "===>  Running ${RUBY_SETUP} to install"
	@(cd ${INSTALL_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} ${RUBY_FLAGS} ${RUBY_SETUP} install --prefix=${STAGEDIR}
.  endif

.endif	# _INCLUDE_USES_RUBY_MK
