# Handle building and dependency aspects of PHP
#
# Feature:	php
# Usage:	USES=php or USES=php:ARGS
# Valid ARGS:	phpize, ext, zend, build, cli, (cgi|mod), web, embed,
#               (81|82|83|84)
#
#  phpize   : Use to build a PHP extension.
#  ext      : Use to build, install and register a PHP extension.
#  zend     : Use to build, install and register a Zend extension.
#  build    : Set PHP also as a build dependency.
#  cli      : Require the CLI version of PHP.
#  cgi      : Require the CGI version of PHP.
#  mod      : Require the Apache Module for PHP.
#  web      : Require the Apache Module or the CGI version of PHP.
#  embed    : Require the embedded library version of PHP.
#  80       : Specify latest PHP 8.0.x (otherwise use default PHP)
#  81       : Specify latest PHP 8.1.x (otherwise use default PHP)
#  82       : Specify latest PHP 8.2.x (otherwise use default PHP)
#
# If the port requires a predefined set of PHP extensions, they can be
# listed in this way:
#
# PHP_EXTENSIONS=	ext1 ext2 ext3
#
# PHP and Zend extensions built with :ext and :zend are automatically enabled
# when the port is installed.  Each port creates a PHP_EXT_INI_FILE file and
# registers the extension in it.
#
# The PHP_EXT_INI_FILE file has a priority number embeded into its name so that
# extensions are loaded in the right order.  The priority is defined by
# PHP_MOD_PRIORITY and is a number between 00 and 99.
#
# For extensions that do not depend on any extension, the priority is
# automatically set to 20.  Conversely, dependent extensions have their
# priority set to 30.  Some extensions may need to be loaded before
# everything else (e.g. opcache), or after priority 30 extensions.  In those
# cases, add PHP_MOD_PRIORITY=XX in the port's Makefile.
#
# For example:
#
# USES=			php:ext
# PHP_EXTENSIONS=	xml wddx
# PHP_MOD_PRIORITY=	40
#
# The port may define PHP_HEADER_DIRS to copy additional headers to package

.if !defined(_INCLUDE_USES_PHP_MK)
_INCLUDE_USES_PHP_MK=	yes

.  if ${php_ARGS:M84}
PHP_SUFFIX=	84
PHP_DOTVER=	8.4
.  elif ${php_ARGS:M83}
PHP_SUFFIX=	83
PHP_DOTVER=	8.3
.  elif ${php_ARGS:M82}
PHP_SUFFIX=	82
PHP_DOTVER=	8.2
.  elif ${php_ARGS:M81}
PHP_SUFFIX=	81
PHP_DOTVER=	8.1
.  else
PHP_SUFFIX=	${PHP_DEFAULT:S/.//}
PHP_DOTVER=	${PHP_DEFAULT}
.  endif

.  if exists(${LOCALBASE}/etc/php${PHP_SUFFIX}/php.conf)
#	php.conf contains definitions for:
#		PHP_VER      (same as PHP_SUFFIX)
#		PHP_VERSION  (same as PHP_X.Y_VERSION)
#		PHP_SAPI     (e.g. "cli cgi fpm")
#		PHP_EXT_INC  (e.g. "pcre spl")
#		PHP_EXT_DIR  (date format YYYYMMDD)
.    include "${LOCALBASE}/etc/php${PHP_SUFFIX}/php.conf"
.    if !defined(PHP_EXT_DIR)  # should not happen unless php.conf is severely modified
PHP_EXT_DIR!=	${LOCALBASE}/bin/php-config --extension-dir | \
		${SED} -ne 's,^${LOCALBASE}/lib/php${PHP_SUFFIX}/\(.*\),\1,p'
.    endif
.  else		# php.conf missing, which should not happen (not installed?)
PHP_VER=	${PHP_SUFFIX}
PHP_VERSION=	${PHP_${PHP_DOTVER}_VERSION}
PHP_SAPI=	# assume none
.      if ${PHP_SUFFIX} == 84
PHP_EXT_DIR=	20240924
PHP_EXT_INC=	hash json pcre spl
.    elif ${PHP_SUFFIX} == 83
PHP_EXT_DIR=	20230831
PHP_EXT_INC=	hash json pcre spl
.    elif ${PHP_SUFFIX} == 82
PHP_EXT_DIR=	20220829
PHP_EXT_INC=	hash json pcre spl
.    elif ${PHP_SUFFIX} == 81
PHP_EXT_DIR=	20210902
PHP_EXT_INC=	hash json pcre spl
.    endif
.  endif
PHPXX=		php${PHP_VER}

.undef DEV_WARNING
.undef USAGE_ERROR
.undef MULTIPLE_PHP
.  if ${php_ARGS:Mbuild} && ( ${php_ARGS:Mphpize} || ${php_ARGS:Mext} || ${php_ARGS:Mzend} )
DEV_WARNING+=	"USES=php:build is included in USES=php:phpize, USES=php:ext, and USES=php:zend, so it is not needed"
.  endif
.  if ${php_ARGS:Mphpize} && ( ${php_ARGS:Mext} || ${php_ARGS:Mzend} )
DEV_WARNING+=	"USES=php:phpize is included in USES=php:ext and USES=php:zend, so it is not needed"
.  endif
.  if ${php_ARGS:Mext} && ${php_ARGS:Mzend}
DEV_WARNING+=	"USES=php:ext is included in USES=php:zend, so it is not needed"
.  endif
.  if ${php_ARGS:Mweb}
.    if ${php_ARGS:Mcgi} || ${php_ARGS:Mmod}
USAGE_ERROR+=	"If you use :web you cannot also use :cgi or :mod.  Pick one."
.    endif
.  endif
.  if ${php_ARGS:Mcgi}
.    if defined(PHP_VERSION) && ${PHP_SAPI:Mcgi} == "" && ${PHP_SAPI:Mfpm} == ""
USAGE_ERROR+=	"This port requires the CGI version of PHP, but the installed PHP is not capable of CGI."
.    endif
.  endif
.  if ${php_ARGS:Mcli}
.    if defined(PHP_VERSION) && ${PHP_SAPI:Mcli} == ""
USAGE_ERROR+=	"This port requires the CLI version of PHP, but the installed PHP is not capable of CLI."
.    endif
.  endif
.  if ${php_ARGS:Membed}
.    if defined(PHP_VERSION) && ${PHP_SAPI:Membed} == ""
USAGE_ERROR+=	"This port requires the embedded PHP library, but the installed PHP does not contain it."
.    endif
.  endif
.  if ${php_ARGS:M82}
.    if ${php_ARGS:M80} || ${php_ARGS:M81}
MULTIPLE_PHP=	yes
.    endif
.  endif
.  if ${php_ARGS:M81}
.    if ${php_ARGS:M80} || ${php_ARGS:M82}
MULTIPLE_PHP=	yes
.    endif
.  endif
.  if ${php_ARGS:M80}
.    if ${php_ARGS:M81} || ${php_ARGS:M82}
MULTIPLE_PHP=	yes
.    endif
.  endif
.  if defined(MULTIPLE_PHP)
USAGE_ERROR+=	"Multiple versions detected.  Pick 80, 81, or 82 ONLY."
.  endif

.  if defined(DEV_WARNING)
_USES_fetch+= 50:php-warning
php-warning:
	@${ECHO_CMD} ${DEV_WARNING}
.  endif

.  if defined(USAGE_ERROR)
_USES_fetch+= 51:php-error
php-error:
	@${ECHO_CMD} ${USAGE_ERROR}
	@${FALSE}
.  endif

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# If args contain "build" or "phpize" or "ext" or "zend"
# BUILDRUN_DEPENDS+= php${PHP_SUFFIX}:primary:std
# BUILD_DEPENDS+=    php${PHP_SUFFIX}:dev:std
# else
# RUN_DEPENDS+=      php${PHP_SUFFIX}:primary:std
# endif
# if args contain "phpize" or "ext" or "zend"
# BUILD_DEPENDS+=    autoconf:single:std
# endif
# Each extension may have individual port dependencies,
# which are listed on the individual makefile.

PLIST_SUB+=	PHP_EXT_DIR=${PHP_EXT_DIR}
SUB_LIST+=	PHP_EXT_DIR=${PHP_EXT_DIR}

.  if ${php_ARGS:Mphpize} || ${php_ARGS:Mext} || ${php_ARGS:Mzend}
GNU_CONFIGURE=		yes
CONFIGURE_ARGS+=	--with-php-config=${LOCALBASE}/bin/php-config${PHP_VER}
PHP_HEADER_DIRS+=	.

_USES_configure+=	325:php-autoconf
_USES_stage+=		935:add-plist-phpext
_USES_extract+=		660:add-desc-phpext

configure-message: phpize-message do-phpize

phpize-message:
	@${ECHO_MSG} "===>  PHPizing for ${TWO_PART_ID}"

do-phpize:
	@(cd ${WRKSRC} && ${SETENV} ${SCRIPTS_ENV} ${LOCALBASE}/bin/phpize${PHP_VER})

php-autoconf:
	@(cd ${CONFIGURE_WRKSRC} && ${LOCALBASE}/bin/autoconf)

.  endif	# args = phpize | ext | zend

.  if ${php_ARGS:Mext} || ${php_ARGS:Mzend}
PHP_MODNAME?=		${NAMEBASE:C/php..-//}
#	Define module load priority (see notes above)
.    if !defined(PHP_MOD_PRIORITY)
.      if defined(PHP_EXTENSIONS)
PHP_MOD_PRIORITY=	30
.      else
PHP_MOD_PRIORITY=	20
.      endif
.    endif
PHP_EXT_INI_FILE=	etc/${PHPXX}/ext-${PHP_MOD_PRIORITY}-${PHP_MODNAME}.ini

.    if ${php_ARGS:Mzend}
TYPEXT="zend_extension=${PHP_MODNAME}.so"
.    else
TYPEXT="extension=${PHP_MODNAME}.so"
.    endif

do-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/lib/${PHPXX}/${PHP_EXT_DIR}
	@${INSTALL_LIB} ${WRKSRC}/modules/${PHP_MODNAME}.so \
		${STAGEDIR}${PREFIX}/lib/${PHPXX}/${PHP_EXT_DIR}
.    for header in ${PHP_HEADER_DIRS}
		@${MKDIR} ${STAGEDIR}${PREFIX}/include/${PHPXX}/ext/${PHP_MODNAME}/${header}
		@${INSTALL_DATA} ${WRKSRC}/${header}/*.h \
			${STAGEDIR}${PREFIX}/include/${PHPXX}/ext/${PHP_MODNAME}/${header}
.    endfor
	@${RM} ${STAGEDIR}${PREFIX}/include/${PHPXX}/ext/${PHP_MODNAME}/config.h
	@${EGREP} "#define (COMPILE|HAVE|USE)_" ${WRKSRC}/config.h \
		> ${STAGEDIR}${PREFIX}/include/${PHPXX}/ext/${PHP_MODNAME}/config.h
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/${PHPXX}
.    if ${php_ARGS:Mzend}
	@${ECHO_CMD} "zend_extension=${PHP_MODNAME}.so" > ${STAGEDIR}${PREFIX}/${PHP_EXT_INI_FILE}
.    else
	@${ECHO_CMD} "extension=${PHP_MODNAME}.so" > ${STAGEDIR}${PREFIX}/${PHP_EXT_INI_FILE}
.    endif

add-plist-phpext:
	# by definition, php extensions are always in the "single" subpackage
	@${ECHO_CMD} "lib/${PHPXX}/${PHP_EXT_DIR}/${PHP_MODNAME}.so" \
		>> ${WRKDIR}/.manifest.single.mktmp
	@${FIND} -P ${STAGEDIR}${PREFIX}/include/${PHPXX}/ext/${PHP_MODNAME} ! -type d 2>/dev/null | \
		${SED} -ne 's,^${STAGEDIR}${PREFIX}/,,p' \
		>> ${WRKDIR}/.manifest.single.mktmp
	@${ECHO_CMD} "${PHP_EXT_INI_FILE}" \
		>> ${WRKDIR}/.manifest.single.mktmp
	# old postexec/postunexec commands
	@${SH} ${MK_SCRIPTS}/php_heredoc.sh script "${_SCRIPT_FILE}.single" \
		"${PHP_MODNAME}" "${PHPXX}"

	# message file located at ${WRKDIR}/.PKG_DISPLAY.single
	@${SH} ${MK_SCRIPTS}/php_heredoc.sh message "${_MESSAGE_FILE}.single" \
		"${PHP_MODNAME}" "${TYPEXT}" "${PREFIX}/${PHP_EXT_INI_FILE}"

add-desc-phpext:
.    if !exists(${_DESC_FILE}.single)
	@${ECHO} "This package contains the ${PHP_MODNAME} extension for PHP ${PHP_DOTVER}." \
	> ${_DESC_FILE}.single
.    endif

.  endif	# args = ext | zend

.endif
