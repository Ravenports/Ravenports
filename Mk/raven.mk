# Copyright (C) 2017 John R. Marino
# This file is covered by the Internet Software Consortium (ISC) License
#
# This is the master makefile logic for the Ravenports system.
# Use 8-column hard tabs
#

RAVENBASE?=		/raven
WRKDIRPREFIX?=		/usr/obj/raven
DISTDIR?=		${RAVENBASE}/distfiles
PACKAGES?=		${RAVENBASE}/packages
LOCALBASE?=		/raven
PREFIX?=		${LOCALBASE}

.include "/xports/Mk/raven.commands.mk"

NAMEBASE?=		undefined	# dummy, must be defined by port makefile
VARIANT?=		standard	# must be defined by ravenadm
SUBPACKAGES?=		single		# must be defined by ravenadm; list
TWO_PART_ID=		${NAMEBASE}-${VARIANT}
PKGNAMEBASE=		${NAMEBASE}__${VARIANT}
DISTNAME?=		${NAMEBASE}-${VERSION}
WRKDIR=			${WRKDIRPREFIX}/${NAMEBASE}
MK_SCRIPTS=		/xports/Mk/Scripts
MK_TEMPLATES=		/xports/Mk/Templates
MK_KEYWORDS=		/xports/Mk/Keywords
SCRIPTDIR=		${.CURDIR}/scripts
PATCHDIR=		${.CURDIR}/patches
FILESDIR=		${.CURDIR}/files
MANIFESTDIR=		${.CURDIR}/manifests
PKGMESSAGE?=		${.CURDIR}/files/pkg-message
PKGINSTALL?=		${.CURDIR}/files/pkg-install
PKGDEINSTALL?=		${.CURDIR}/files/pkg-deinstall

_DISTINFO_FILE=		${.CURDIR}/distinfo

.for N in ${DF_INDEX}
.  if defined(DIRTY_EXTRACT_${N})
EXTRACT_WRKDIR_${N}=	${WRKDIR}/${NAMEBASE}_${N}
.  else
EXTRACT_WRKDIR_${N}=	${WRKDIR}
.  endif
.endfor

.if defined(DIRTY_EXTRACT_1)
WRKSRC=			${WRKDIR}/${NAMEBASE}_1
.else
.  if defined(USE_GITHUB)
WRKSRC=			${WRKDIR}/${GH_PROJECT}-${GH_TAGNAME_EXTRACT}
.  else
WRKSRC=			${WRKDIR}/${DISTNAME}
.  endif
.endif

# --------------------------------------------------------------------------
# --  Common Definitions
# --------------------------------------------------------------------------

# These require modification to bmake (which Ravenports have)
# Some systems have different names for same architecture
#   FreeBSD   ARCH=amd64  ARCH_STANDARD=x86_64
#   DragonFly ARCH=x86_64 ARCH_STANDARD=x86_64

OPSYS?=			${.MAKE.OS.NAME}
OSVERSION?=		${.MAKE.OS.VERSION}
OSREL?=			${.MAKE.OS.RELEASE}
MAJOR?=			${.MAKE.OS.MAJOR}
ARCH?=			${.MAKE.OS.ARCHITECTURE}
ARCH_STANDARD?=		${.MAKE.OS.ARCH.STANDARD}

# --------------------------------------------------------------------------
# --  Debugging
# --------------------------------------------------------------------------

# How to do nothing.  Override to make it do nothing differently
DO_NADA?=		${TRUE}

# --------------------------------------------------------------------------
# --  Phase: Fetch
# --------------------------------------------------------------------------

.if !make(makesum)
FETCH_ENV=		SSL_NO_VERIFY_PEER=1 SSL_NO_VERIFY_HOSTNAME=1
.endif
FETCH_REGET?=		1

_OFFICIAL_BACKUP=	http://distcache.FreeBSD.org/ports-distfiles/ # placeholder (change this)
DL_SITE_BACKUP?=	${_OFFICIAL_BACKUP}

.if defined(DL_SITE_DISABLE)
_DL_SITE_OVERRIDE:=	${_OFFICIAL_BACKUP}
_DL_SITE_BACKUP=	# disabled
.else
_DL_SITE_OVERRIDE=	${DL_SITE_OVERRIDE}
_DL_SITE_BACKUP=	${DL_SITE_BACKUP}
.endif

# Sort the master site list according to the patterns in MASTER_SORT
MSR=			://[^/]*/
MASTER_SORT_AWK= 	BEGIN { RS = " "; ORS = " "; IGNORECASE = 1 ; gl = "${MSR:S|\\|\\\\|g}"; } \
			/${MSR:S|/|\\/|g}/ { good["${MSR:S|\\|\\\\|g}"] = good["${MSR:S|\\|\\\\|g}"] " " $$0 ; next; } \
			{ rest = rest " " $$0; } END { n=split(gl, gla); for(i=1;i<=n;i++) { print good[gla[i]]; } print rest; }

_DISTFILES:=
_PATCHFILES:=
_CKSUMFILES:=
_DL_SITES_ENV:=
_PATCH_SITES_ENV:=
.for N in ${DF_INDEX}
_F=		${DISTFILE_${N}}
_F_TEMP=	${_F:S/^${_F:C/:[^:]+$//}//:S/^://}
_DISTFILES:=	${_DISTFILES} ${_F}
_CKSUMFILES:=	${_CKSUMFILES} ${_F:C/:.*//}
.  for _group in ${_F_TEMP:S/,/ /g}
.    if defined(DL_SITES_${_group})
_DL_SITES_ENV+=		_DOWNLOAD_SITES_${_group}=${DL_SITES_${_group}:Q}
.    endif
.  endfor
.endfor
.for N in ${PF_INDEX}
_F=		${PATCHFILE_${N}}
_F_TEMP=	${_F:S/^${_F:C/:[^-:][^:]*$//}//:S/^://}
_PATCHFILES:=	${_PATCHFILES} ${_F}
_CKSUMFILES:=	${_CKSUMFILES} ${_F:C/:.*//}
.  if !empty(_F_TEMP)
.    for _group in ${_F_TEMP:S/,/ /g}
.      if defined(DL_SITES_${_group})
_PATCH_SITES_ENV+=	_DOWNLOAD_SITES_${_group}=${DL_SITES_${_group}:Q}
.      endif
.    endfor
.  endif
.endfor
.if defined(DIST_SUBDIR)
_CKSUMFILES:=	${_CKSUMFILES:S/^/${DIST_SUBDIR}\//}
.endif

_DO_FETCH_ENV= 		dp_DISTDIR='${DISTDIR}' \
			dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
			dp_DIST_SUBDIR='${DIST_SUBDIR}' \
			dp_ECHO_MSG='${ECHO_MSG}' \
			dp_FETCH_CMD='${FETCH_CMD}' \
			dp_FETCH_ENV=${FETCH_ENV:Q} \
			dp_FORCE_FETCH_ALL= \
			dp_FORCE_FETCH_LIST='${FORCE_FETCH_LIST}' \
			dp_MASTER_SITE_BACKUP='${_DL_SITE_BACKUP}' \
			dp_MASTER_SITE_OVERRIDE='${_DL_SITE_OVERRIDE}' \
			dp_MASTER_SORT_AWK='${MASTER_SORT_AWK}' \
			dp_DISABLE_CHECKSUM='${SKIP_CHECKSUM}' \
			dp_DISABLE_SIZE= \
			dp_SCRIPTSDIR='${MK_SCRIPTS}' \
			dp_TARGET='${.TARGET}' \
			# end

.if !target(do-fetch)
do-fetch:
.  if !empty(_DISTFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_DL_SITES_ENV} \
		${SH} ${MK_SCRIPTS}/do-fetch.sh ${_DISTFILES:C/.*/'&'/}
.  endif
.  if !empty(_PATCHFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_PATCH_SITES_ENV} \
		${SH} ${MK_SCRIPTS}/do-fetch.sh ${_PATCHFILES:C/:-p[0-9]//:C/.*/'&'/}
.  endif
.endif

# --------------------------------------------------------------------------
# --  Phase: Checksum
# --------------------------------------------------------------------------

# List all algorithms here (which is exactly one)
_CHECKSUM_INIT_ENV=	dp_SHA256=${SHA256}

.if !target(checksum)
checksum: fetch
.  if !empty(_CKSUMFILES)
	@${SETENV} \
		${_CHECKSUM_INIT_ENV} \
		dp_CHECKSUM_ALGORITHMS='SHA256' \
		dp_CURDIR='${.CURDIR}' \
		dp_DISTDIR='${DISTDIR}' \
		dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
		dp_DIST_SUBDIR='${DIST_SUBDIR}' \
		dp_ECHO_MSG='${ECHO_MSG}' \
		dp_FETCH_REGET='${FETCH_REGET}' \
		dp_MAKE='${MAKE}' \
		dp_MAKEFLAGS='${.MAKEFLAGS}' \
		dp_SCRIPTSDIR='${MK_SCRIPTS}' \
		dp_DISABLE_SIZE= \
		dp_DISABLE_CHECKSUM= \
		${SH} ${MK_SCRIPTS}/checksum.sh ${_CKSUMFILES:C/.*/'&'/}
.  endif
.endif

# --------------------------------------------------------------------------
# --  Makesum (developer)
# --------------------------------------------------------------------------

.if !target(makesum)
makesum:
.  if !empty(_DISTFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_DL_SITES_ENV} \
		dp_DISABLE_CHECKSUM=yes \
		dp_DISABLE_SIZE=yes \
		${SH} ${MK_SCRIPTS}/do-fetch.sh ${_DISTFILES:C/.*/'&'/}
.  endif
.  if !empty(PATCHFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_PATCH_SITES_ENV} \
		dp_DISABLE_CHECKSUM=yes \
		dp_DISABLE_SIZE=yes \
		${SH} ${MK_SCRIPTS}/do-fetch.sh ${_PATCHFILES:C/:-p[0-9]//:C/.*/'&'/}
.  endif
	@${SETENV} \
		${_CHECKSUM_INIT_ENV} \
		dp_CHECKSUM_ALGORITHMS='SHA256' \
		dp_CKSUMFILES='${_CKSUMFILES}' \
		dp_DISTDIR='${DISTDIR}' \
		dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
		dp_ECHO_MSG='${ECHO_MSG}' \
		dp_SCRIPTSDIR='${MK_SCRIPTS}' \
		${SH} ${MK_SCRIPTS}/makesum.sh ${_DISTFILES:C/.*/'&'/}
.endif

# --------------------------------------------------------------------------
# --  Phase: Extract
# --------------------------------------------------------------------------

# This is what is actually going to be extracted, and is overridable by user.
EXTRACT_ONLY?=	${DF_INDEX}

.for N in ${EXTRACT_ONLY}
EXTRACT_HEAD_${N}?=	${TAR} -xf
EXTRACT_TAIL_${N}?=	--no-same-owner --no-same-permissions
.endfor

clean-wrkdir:
	@${RM} -r ${WRKDIR}

create-extract-dirs:
	@${MKDIR} ${WRKDIR}
.for N in ${EXTRACT_ONLY}
.  if defined (DIRTY_EXTRACT_${N})
	@${MKDIR} ${WRKDIR}/${NAMEBASE}_${N}
.  endif
.endfor

extract-message:
	@${ECHO_MSG} "===>  Extracting for ${TWO_PART_ID}"

extract-fixup-modes:
	@${CHMOD} -R u+w,a+rX ${WRKDIR}

.if !target(apply-slist)
.  for i in pkg-message pkg-install pkg-deinstall
.    if !empty (${SUB_FILES:M${i}.in})
${i:S/-//:tu}=		${WRKDIR}/${SUB_FILES:M${i}}
.    endif
.  endfor
_SUB_LIST_TEMP=		${SUB_LIST:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/}

apply-slist:
.  for file in ${SUB_FILES}
.    if exists(${FILESDIR}/${file}.in)
	@${SED} ${_SUB_LIST_TEMP} -e '/^@comment /d' ${FILESDIR}/${file}.in > ${WRKDIR}/${file}
.    else
	@${ECHO_MSG} "** Checked ${FILESDIR}:"; \
	@${ECHO_MSG} "** Missing ${file}.in for ${TWO_PART_ID}."; \
	exit 1
.    endif
.  endfor
.endif

.if !target(do-extract)
do-extract:
.  for N in ${EXTRACT_ONLY}
	@if ! (cd ${EXTRACT_WRKDIR_${N}} && ${EXTRACT_HEAD_${N}} ${DISTDIR}/${DIST_SUBDIR}/${DISTFILE_${N}:C/:.*//} ${EXTRACT_TAIL_${N}}); \
	then exit 1; fi
.  endfor
	@${CHMOD} -R ug-s ${WRKDIR}
	@${CHOWN} -R 0:0 ${WRKDIR}
.endif

# --------------------------------------------------------------------------
# --  Phase: Patch
# --------------------------------------------------------------------------

PATCH_WRKSRC?=		${WRKSRC}
PATCH_STRIP?=		-p0
PATCH_DIST_STRIP?=	-p0
.if defined(PATCH_DEBUG)
PATCH_ARGS=		-E ${PATCH_STRIP} --batch
PATCH_DIST_ARGS=	--suffix .orig -E ${PATCH_DIST_STRIP} --batch \
			-V simple
.else
PATCH_ARGS=		--forward --quiet -E ${PATCH_STRIP} --batch
PATCH_DIST_ARGS=	--suffix .orig --forward --quiet \
			-E ${PATCH_DIST_STRIP} --batch -V simple
.endif

patch-message:
	@${ECHO_MSG} "===>  Patching for ${TWO_PART_ID}"

.if !target(do-patch)
do-patch:
	@${SETENV} \
		dp_BZCAT="${BZCAT}" \
		dp_CAT="${CAT}" \
		dp_DISTDIR="${DISTDIR}" \
		dp_ECHO_MSG="${ECHO_MSG}" \
		dp_GZCAT="${GZCAT}" \
		dp_OPSYS="${OPSYS}" \
		dp_PATCH="${PATCH}" \
		dp_PATCHDIR="${PATCHDIR}" \
		dp_OPSYS_PATCHDIR="${.CURDIR}/opsys" \
		dp_PATCHFILES="${_PATCHFILES:C/:.*//}" \
		dp_PATCH_ARGS=${PATCH_ARGS:Q} \
		dp_PATCH_DEBUG_TMP="${PATCH_DEBUG:Dyes}" \
		dp_PATCH_DIST_ARGS="${PATCH_DIST_ARGS}" \
		dp_PATCH_SILENT="yes" \
		dp_PATCH_WRKSRC=${PATCH_WRKSRC} \
		dp_PORTID="${TWO_PART_ID}" \
		dp_SCRIPTSDIR="${MK_SCRIPTS}" \
		dp_UNZIP_CMD="${UNZIP_CMD}" \
		dp_XZCAT="${XZCAT}" \
		${SH} ${MK_SCRIPTS}/do-patch.sh
.endif

# --------------------------------------------------------------------------
# --  Clean routines
# --------------------------------------------------------------------------

clean-msg:
	@${ECHO_MSG} "===>  Cleaning for ${TWO_PART_ID}"

.for T in pre-clean post-clean
.  if !target(${T})
${T}:
	@${DO_NADA}
.  endif
.endfor

.if !target(do-clean)
do-clean:
	@if [ -d ${WRKDIR} ]; then \
		if [ -w ${WRKDIR} ]; then \
			${RM} -r ${WRKDIR}; \
			${FIND} ${WRKDIR:H} -type d -maxdepth 1 -empty -delete; \
		else \
			${ECHO_MSG} "===>   ${WRKDIR} not writable, skipping"; \
		fi; \
	fi
.endif

.if !target(clean)
.ORDER: clean-msg pre-clean do-clean post-clean
clean: clean-msg pre-clean do-clean post-clean
.endif

# --------------------------------------------------------------------------
# --  Set up environment
# --------------------------------------------------------------------------

INSTALL=		install
BINMODE?=		555
MANMODE?=		444
SHAREMODE?=		444
_SHAREMODE?=		0644
OPTIMIZER_LEVEL?=	2

.if defined(WITH_DEBUG)
STRIP=			# none
STRIP_CMD=		${TRUE}
DEBUG_FLAGS?=		-g
MAKE_ENV+=		DONTSTRIP=yes
CFLAGS:=		-pipe -O${OPTIMIZER_LEVEL} ${DEBUG_FLAGS} ${CFLAGS}

.  if defined(INSTALL_TARGET)
INSTALL_TARGET:=	${INSTALL_TARGET:S/^install-strip$/install/g}
.  endif
.else
CFLAGS:=		-pipe -O${OPTIMIZER_LEVEL} ${CFLAGS}
.endif

BUILD_TARGET?=		all
INSTALL_TARGET?=	install

INSTALL_PROGRAM=	${INSTALL} ${STRIP} -m ${BINMODE}
INSTALL_LIB=		${INSTALL} ${STRIP} -m ${SHAREMODE}
INSTALL_SCRIPT=		${INSTALL} -m ${BINMODE}
INSTALL_DATA=		${INSTALL} -m ${_SHAREMODE}
INSTALL_MAN=		${INSTALL} -m ${MANMODE}

INSTALL_MACROS=		BSD_INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
			BSD_INSTALL_LIB="${INSTALL_LIB}" \
			BSD_INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
			BSD_INSTALL_DATA="${INSTALL_DATA}" \
			BSD_INSTALL_MAN="${INSTALL_MAN}"

MAKE_ENV+=		${INSTALL_MACROS}
SCRIPTS_ENV+=		${INSTALL_MACROS} \
			CURDIR=${.CURDIR} \
			DISTDIR=${DISTDIR} \
			WRKDIR=${WRKDIR} \
			WRKSRC=${WRKSRC} \
			PATCHDIR=${PATCHDIR} \
			SCRIPTDIR=${SCRIPTDIR} \
			FILESDIR=${FILESDIR} \
			PREFIX=${PREFIX} \
			LOCALBASE=${LOCALBASE}

# --------------------------------------------------------------------------
# --  Phase: Configure
# --------------------------------------------------------------------------

INFO_PATH?=		share/info
MANPREFIX?=		${PREFIX}/share
.if defined(CONFIGURE_OUTSOURCE)
CONFIGURE_CMD=		${WRKSRC}/${CONFIGURE_SCRIPT}
CONFIGURE_WRKSRC?=	${WRKDIR}/.build
.else
CONFIGURE_CMD=		./${CONFIGURE_SCRIPT}
CONFIGURE_WRKSRC?=	${WRKSRC}
.endif
CONFIGURE_SCRIPT?=	configure
CONFIGURE_TARGET?=	${ARCH}-raven-${OPSYS:tl}${OSREL}
CONFIGURE_TARGET:=	${CONFIGURE_TARGET:S/--build=//}
CONFIGURE_LOG=		config.log
CONFIGURE_FAIL_MESSAGE=	"Please report the problem and attach the\
\"${CONFIGURE_WRKSRC}/${CONFIGURE_LOG}\" including the output of the\
failure of your make command."

.if defined(GNU_CONFIGURE)
HAS_CONFIGURE=			yes
GNU_CONFIGURE_PREFIX?=		${PREFIX}
GNU_CONFIGURE_MANPREFIX=	${MANPREFIX}
CONFIG_SITE=			${MK_TEMPLATES}/config.site
CONFIGURE_ARGS+=		--prefix=${GNU_CONFIGURE_PREFIX} \
				$${_LATE_CONFIGURE_ARGS}
CONFIGURE_ENV+=			CONFIG_SITE=${CONFIG_SITE}
SET_LATE_CONFIGURE_ARGS= \
     _LATE_CONFIGURE_ARGS="" ; \
	if [ -z "${CONFIGURE_ARGS:M--localstatedir=*:Q}" ] && \
	   ${CONFIGURE_CMD} --help 2>&1 | ${GREP} -- --localstatedir > /dev/null; then \
	    _LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} --localstatedir=/var" ; \
	fi ; \
	if [ ! -z "`${CONFIGURE_CMD} --help 2>&1 | ${GREP} -- '--mandir'`" ]; then \
	    _LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} --mandir=${GNU_CONFIGURE_MANPREFIX}/man" ; \
	fi ; \
	if [ ! -z "`${CONFIGURE_CMD} --help 2>&1 | ${GREP} -- '--disable-silent-rules'`" ]; then \
	    _LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} --disable-silent-rules" ; \
	fi ; \
	if [ ! -z "`${CONFIGURE_CMD} --help 2>&1 | ${GREP} -- '--infodir'`" ]; then \
	    _LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} --infodir=${GNU_CONFIGURE_PREFIX}/${INFO_PATH}/${INFO_SUBDIR}" ; \
	fi ; \
	if [ -z "`${CONFIGURE_CMD} --version 2>&1 | ${EGREP} -i '(autoconf.*2\.13|Unrecognized option)'`" ]; then \
		_LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} --build=${CONFIGURE_TARGET}" ; \
	else \
		_LATE_CONFIGURE_ARGS="$${_LATE_CONFIGURE_ARGS} ${CONFIGURE_TARGET}" ; \
	fi;
.endif

configure-message:
	@${ECHO_MSG} "===>  Configuring for ${TWO_PART_ID}"

.if !target(run-autotools-fixup)
run-autotools-fixup:
.  if ${OPSYS} == FreeBSD && defined(APPLY_F10_FIX)
	-@for f in `${FIND} ${WRKDIR} -type f \( -name config.libpath -o \
		-name config.rpath -o -name configure -o -name libtool.m4 -o \
		-name ltconfig -o -name libtool -o -name aclocal.m4 -o \
		-name acinclude.m4 \)` ; do \
			${SED} -i.fbsd10bak \
				-e 's|freebsd1\*)|freebsd1.\*)|g' \
				-e 's|freebsd\[12\]\*)|freebsd[12].*)|g' \
				-e 's|freebsd\[123\]\*)|freebsd[123].*)|g' \
				-e 's|freebsd\[\[12\]\]\*)|freebsd[[12]].*)|g' \
				-e 's|freebsd\[\[123\]\]\*)|freebsd[[123]].*)|g' \
					$${f} ; \
			cmp -s $${f}.fbsd10bak $${f} || \
			${ECHO_MSG} "===>   FreeBSD 10 autotools fix applied to $${f}"; \
			${TOUCH} ${TOUCH_FLAGS} -mr $${f}.fbsd10bak $${f} ; \
			${RM} $${f}.fbsd10bak ; \
		done
.  endif
.endif

.if !target(do-configure)
do-configure:
	@if [ -f ${SCRIPTDIR}/configure ]; then \
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH} \
		  ${SCRIPTDIR}/configure; \
	fi
.  if defined(GNU_CONFIGURE)
	@CONFIG_GUESS_DIRS=$$(${FIND} ${WRKDIR} -name config.guess -o -name config.sub \
		| ${XARGS} -n 1 ${DIRNAME}); \
	for _D in $${CONFIG_GUESS_DIRS}; do \
		${RM} $${_D}/config.guess; \
		${CP} ${MK_TEMPLATES}/config.guess $${_D}/config.guess; \
		${CHMOD} a+rx $${_D}/config.guess; \
		${RM} $${_D}/config.sub; \
		${CP} ${MK_TEMPLATES}/config.sub $${_D}/config.sub; \
		${CHMOD} a+rx $${_D}/config.sub; \
	done
.  endif
.  if defined(HAS_CONFIGURE)
	@${MKDIR} ${CONFIGURE_WRKSRC}
	@(cd ${CONFIGURE_WRKSRC} && \
	    ${SET_LATE_CONFIGURE_ARGS} \
		if ! ${SETENV} CC="${CC}" CPP="${CPP}" CXX="${CXX}" \
	    CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS}" \
	    LDFLAGS="${LDFLAGS}" LIBS="${LIBS}" \
	    INSTALL="/usr/bin/install -c" \
	    INSTALL_DATA="${INSTALL_DATA}" \
	    INSTALL_LIB="${INSTALL_LIB}" \
	    INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
	    INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
	    ${CONFIGURE_ENV} ${CONFIGURE_CMD} ${CONFIGURE_ARGS}; then \
			 ${ECHO_MSG} "===>  Script \"${CONFIGURE_SCRIPT}\" failed unexpectedly."; \
			 (${ECHO_CMD} ${CONFIGURE_FAIL_MESSAGE}); \
			 ${FALSE}; \
		fi)
.  endif
.endif

# --------------------------------------------------------------------------
# --  Phase: Build
# --------------------------------------------------------------------------

MAKE_CMD?=		${BSDMAKE}
MAKEFILE?=		Makefile
MAKE_ENV+=		PREFIX=${PREFIX} \
			LOCALBASE=${LOCALBASE} \
			LIBDIR="${LIBDIR}" \
			CC="${CC}" CFLAGS="${CFLAGS}" \
			CPP="${CPP}" CPPFLAGS="${CPPFLAGS}" \
			LDFLAGS="${LDFLAGS}" LIBS="${LIBS}" \
			CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
			MANPREFIX="${MANPREFIX}"
DESTDIRNAME?=		DESTDIR
STAGEDIR=		${WRKDIR}/stage
.if defined(CONFIGURE_OUTSOURCE)
BUILD_WRKSRC?=		${WRKDIR}/.build
.else
BUILD_WRKSRC?=		${WRKSRC}
.endif

.if defined(DESTDIR_VIA_ENV)
MAKE_ENV+=		${DESTDIRNAME}=${STAGEDIR}
.else
MAKE_ARGS+=		${DESTDIRNAME}=${STAGEDIR}
.endif

.for lang in C CXX
.  if defined(USE_${lang}STD)
${lang}FLAGS:=	${${lang}FLAGS:N-std=*} -std=${USE_${lang}STD}
.  endif

.  if defined(${lang}FLAGS_${ARCH})
${lang}FLAGS+=	${${lang}FLAGS_${ARCH}}
.  endif
.endfor

.undef (BUILD_FAIL_MESSAGE)

# Multiple make jobs support
.if defined(DISABLE_MAKE_JOBS) || defined(SINGLE_JOB)
_MAKE_JOBS=		#
MAKE_JOBS_NUMBER=	1
.else
.  if defined(MAKE_JOBS_NUMBER)
_MAKE_JOBS_NUMBER:=	${MAKE_JOBS_NUMBER}
.  else
.    if !defined(NUMBER_CPUS)
.error 'NUMBER_CPUS' must be defined in toplevel make.conf
.    endif
_MAKE_JOBS_NUMBER=	${NUMBER_CPUS}
.  endif
.  if defined(MAKE_JOBS_NUMBER_LIMIT) && ( ${MAKE_JOBS_NUMBER_LIMIT} < ${_MAKE_JOBS_NUMBER} )
MAKE_JOBS_NUMBER=	${MAKE_JOBS_NUMBER_LIMIT}
.  else
MAKE_JOBS_NUMBER=	${_MAKE_JOBS_NUMBER}
.  endif
_MAKE_JOBS?=		-j${MAKE_JOBS_NUMBER}
BUILD_FAIL_MESSAGE=	Try to set SINGLE_JOBS=yes and rebuild before reporting the failure.
.endif

DO_MAKE_BUILD?=		${SETENV} ${MAKE_ENV} ${MAKE_CMD} ${MAKE_FLAGS} \
			${MAKEFILE} ${_MAKE_JOBS} ${MAKE_ARGS:C,^${DESTDIRNAME}=.*,,g}

.if defined(WITH_CCACHE_BUILD) && !defined(NO_CCACHE) && !defined(NO_BUILD)
#TODO: Add build dependency on ccache port
#TODO: Obviously ccache port has to have NO_CCACHE set to avoid cycle
CCACHE_DIR?=		/root/.ccache
_CCACHE_PATH=		${LOCALBASE}/libexec/ccache

# Prepend the ccache dir into the PATH and setup ccache env
PATH:=	${_CCACHE_PATH}:${PATH}
.  if !${MAKE_ENV:MPATH=*} && !${CONFIGURE_ENV:MPATH=*}
MAKE_ENV+=		PATH=${PATH} CCACHE_DIR="${CCACHE_DIR}"
CONFIGURE_ENV+=		PATH=${PATH} CCACHE_DIR="${CCACHE_DIR}"
.  endif
.endif

build-message:
	@${ECHO_MSG} "===>  Building for ${TWO_PART_ID}"

.if !target(do-build)
do-build:
	@(cd ${BUILD_WRKSRC}; if ! ${DO_MAKE_BUILD} ${BUILD_TARGET}; then \
		if [ -n "${BUILD_FAIL_MESSAGE}" ] ; then \
			${ECHO_MSG} "===> Compilation failed unexpectedly."; \
			(${ECHO_CMD} "${BUILD_FAIL_MESSAGE}"); \
		fi; \
		${FALSE}; \
	fi)
.endif

# --------------------------------------------------------------------------
# --  Phase: Stage
# --------------------------------------------------------------------------

MANDIRS=		${MANPREFIX}/man
.for sect in 1 2 3 4 5 6 7 8 9 L N
MAN${sect}PREFIX?=	${MANPREFIX}
.endfor

.if defined(CONFIGURE_OUTSOURCE)
INSTALL_WRKSRC?=	${WRKDIR}/.build
.else
INSTALL_WRKSRC?=	${WRKSRC}
.endif

stage-message:
	@${ECHO_MSG} "===>  Staging for ${TWO_PART_ID}"

.if !target(stage-dir)
stage-dir:
	@${MKDIR} \
		${STAGEDIR}${PREFIX}/bin \
		${STAGEDIR}${PREFIX}/etc/rc.d \
		${STAGEDIR}${PREFIX}/include \
		${STAGEDIR}${PREFIX}/lib/pkgconfig \
		${STAGEDIR}${PREFIX}/libdata \
		${STAGEDIR}${PREFIX}/libexec \
		${STAGEDIR}${PREFIX}/sbin \
		${STAGEDIR}${PREFIX}/share/doc \
		${STAGEDIR}${PREFIX}/share/examples \
		${STAGEDIR}${PREFIX}/share/info \
		${STAGEDIR}${PREFIX}/share/locale \
		${STAGEDIR}${PREFIX}/share/man/man1 \
		${STAGEDIR}${PREFIX}/share/man/man2 \
		${STAGEDIR}${PREFIX}/share/man/man3 \
		${STAGEDIR}${PREFIX}/share/man/man4 \
		${STAGEDIR}${PREFIX}/share/man/man5 \
		${STAGEDIR}${PREFIX}/share/man/man6 \
		${STAGEDIR}${PREFIX}/share/man/man7 \
		${STAGEDIR}${PREFIX}/share/man/man8 \
		${STAGEDIR}${PREFIX}/share/man/man9 \
		${STAGEDIR}${PREFIX}/share/man/mann \
		${STAGEDIR}${PREFIX}/share/man/manl \
		${STAGEDIR}${PREFIX}/share/nls \
		${STAGEDIR}${PREFIX}/www \
		# end
.endif

.if !target(do-install) && !defined(NO_INSTALL)
do-install:
	@(cd ${INSTALL_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${MAKE_CMD} ${MAKE_FLAGS} ${MAKEFILE} ${MAKE_ARGS} \
		${INSTALL_TARGET})
.endif

# Compress all manpage not already compressed and also not hardlinks
# Find all manpages which are not compressed and are hadlinks, and only
# get the list of inodes concerned, for each of them compress the first
# one found and recreate the hardlinks for the others.
# Fixes all dead symlinks left by the previous round.

.if !target(compress-man)
compress-man:
	@${ECHO_MSG} "====> Compressing man pages (compress-man)"
	@mdirs= ; \
	for dir in ${MANDIRS:S/^/${STAGEDIR}/} ; do \
		[ -d $$dir ] && mdirs="$$mdirs $$dir" ;\
	done ; \
	for dir in $$mdirs; do \
		${FIND} $$dir -type f \! -name "*.gz" -links 1 -exec ${GZIP_CMD} {} \; ; \
		${FIND} $$dir -type f \! -name "*.gz" \! -links 1 -exec ${STAT} -f '%i' {} \; | \
			${SORT} -u | while read inode ; do \
				unset ref ; \
				for f in $$(${FIND} $$dir -type f -inum $${inode} -print); do \
					if [ -z $$ref ]; then \
						ref=$${f}.gz ; \
						${GZIP_CMD} $${f} ; \
						continue ; \
					fi ; \
					${RM} $${f} ; \
					(cd $${f%/*}; ${LN} -f $${ref##*/} $${f##*/}.gz) ; \
				done ; \
			done ; \
		${FIND} $$dir -type l \! -name "*.gz" | while read link ; do \
				${LN} -sf $$(readlink $$link).gz $$link.gz ;\
				${RM} $$link ; \
		done; \
	done
.endif

.if !target(install-rc-script)
.undef RC_SUBR_USED
.  for sp in ${SUBPACKAGES}
.    if defined(RC_SUBR_${sp}) && !empty(RC_SUBR__${sp})
RC_SUBR_USED=	yes
.    endif
.  endfor
.  if defined(RC_SUBR_USED)
install-rc-script:
.    for sp in ${SUBPACKAGES}
.      if defined(RC_SUBR_${sp}) && !empty(RC_SUBR__${sp})
	@${ECHO_MSG} "===> Staging rc.d startup scripts (${sp})"
	@for i in ${RC_SUBR_${sp}}; do \
		_prefix=${PREFIX}; \
		[ "${PREFIX}" = "/usr" ] && _prefix="" ; \
		${INSTALL_SCRIPT} ${WRKDIR}/$${i} ${STAGEDIR}$${_prefix}/etc/rc.d/$${i%.sh}; \
		${ECHO_CMD} "$${_prefix}/etc/rc.d/$${i%.sh}" \
		>> >> ${WRKDIR}/.manifest.${sp}.mktmp; \
	done
.      endif
.    endfor
.  endif
.endif

# --------------------------------------------------------------------------
# --  Manifest handling
# --------------------------------------------------------------------------

TMP_MANIFESTS=		${SUBPACKAGES:C|(.*)|${WRKDIR}/.manifest.\1.mktmp|}
TMP_MANIFESTS_SORT=	${TMP_MANIFESTS:.mktmp=.mktmp.sorted}

.for plist in ${TMP_MANIFESTS}
${plist}.sorted: ${plist}
	@${SORT} -u ${.ALLSRC} > ${.TARGET}
.endfor

generate-plist: ${TMP_MANIFESTS}

${TMP_MANIFESTS}:
	@${ECHO_MSG} "===>   Generating temporary packing list (${.TARGET:R:E})"
	@${MKDIR} ${.TARGET:H}
	@${TOUCH} ${.TARGET}
	@if [ -f ${.CURDIR}/manifests/plist.${.TARGET:R:E} ]; then \
		${SED} ${PLIST_SUB:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/} \
		${.CURDIR}/manifests/plist.${.TARGET:R:E} >> ${.TARGET}; \
	elif [ -f ${.CURDIR}/manifests/plist.${.TARGET:R:E}.${VARIANT} ]; then \
		${SED} ${PLIST_SUB:S/$/!g/:S/^/ -e s!%%/:S/=/%%!/} \
		${.CURDIR}/manifests/plist.${.TARGET:R:E}.${VARIANT} >> ${.TARGET}; \
	fi

.undef INFO_USED
.undef INFO_SUBDIR
.for sp in ${SUBPACKAGES}
.  if defined(INFO_${sp}) && !empty(INFO_${sp})
INFO_USED=	yes
.    for D in ${INFO_${sp}:H}
RD:=		${D}
.      if ${RD} != "."
.        if !defined(INFO_SUBDIR)
INFO_SUBDIR:=	${RD}
.        endif
.      endif
.    endfor
.  endif
.endfor
.undef RD

.if defined(INFO_USED)
# TODO: Add RUN_DEPENDS on indexinfo
.endif

.if !target(add-plist-info)
add-plist-info:
.  for sp in ${SUBPACKAGES}
.    for i in ${INFO_${sp}}
	@${LS} ${STAGEDIR}${PREFIX}/${INFO_PATH}/$i.info* | \
	${SED} -e s:${STAGEDIR}:@info\ :g >> ${.CURDIR}/manifest.${sp}.mktmp
.    endfor
.  endfor
.endif

# If we're installing into a non-standard PREFIX, we need to remove that
# directory at deinstall-time.  At this time, PREFIX should be prohibited
# from being "/usr" or "/" but leave the check in anyway.

.if !target(add-plist-post)
.  if (${PREFIX} != ${LOCALBASE} && ${PREFIX} != "/usr" && ${PREFIX} != "/")
add-plist-post:
.    for sp in ${SUBPACKAGES}
	@${ECHO_CMD} "@dir ${PREFIX}" >> ${.CURDIR}/manifest.${sp}.mktmp
.    endfor
.  endif
.endif

# "docs" is a standard subpackage name.
# All port docs must be located at ${PREFIX}/share/docs/${NAMEBASE}
# If manifests/docs.${VARIANT} does not exist (which is handled by
# generate-plist target already), autogeneration is assumed.

.if !target(add-plist-docs)
.  if ${SUBPACKAGES:Mdocs}
.    if !exists(${.CURDIR}/manifests/docs.${VARIANT})
add-plist-docs:
	@${FIND} -s ${STAGEDIR}${PREFIX}/share/docs \
	\( -type f -o -type l \) 2>/dev/null >> ${WRKDIR}/.manifest.docs.mktmp
.    endif
.  endif
.endif

# "examples" is a standard subpackage name.
# All port examples must be located at ${PREFIX}/share/examples/${NAMEBASE}
# If manifests/examples.${VARIANT} does not exist (which is handled by
# generate-plist target already), autogeneration is assumed.

.if !target(add-plist-examples)
.  if ${SUBPACKAGES:Mexamples}
.    if !exists(${.CURDIR}/manifests/examples.${VARIANT})
add-plist-examples:
	@${FIND} -s ${STAGEDIR}${PREFIX}/share/examples \
	\( -type f -o -type l \) 2>/dev/null >> ${WRKDIR}/.manifest.examples.mktmp
.    endif
.  endif
.endif

# --------------------------------------------------------------------------
# --  Phase: Test (optional)
# --------------------------------------------------------------------------

.if defined(CONFIGURE_OUTSOURCE)
TEST_WRKSRC?=	${WRKDIR}/.build
.else
TEST_WRKSRC?=	${WRKSRC}
.endif

test-message:
	@${ECHO_MSG} "===>  Testing for ${TWO_PART_ID}"

.if !target(do-test) && defined(TEST_TARGET)
DO_MAKE_TEST?=		${SETENV} ${TEST_ENV} ${MAKE_CMD} ${MAKE_FLAGS} \
			${MAKEFILE} ${TEST_ARGS:C,^${DESTDIRNAME}=.*,,g}
do-test:
	@(cd ${TEST_WRKSRC}; \
	if ! ${DO_MAKE_TEST} ${TEST_TARGET}; then \
		if [ -n "${TEST_FAIL_MESSAGE}" ] ; then \
			${ECHO_MSG} "===> Tests failed unexpectedly."; \
			(${ECHO_CMD} "${TEST_FAIL_MESSAGE}"); \
		fi; \
		${FALSE}; \
	fi)
.elif !target(do-test)
do-test:
	@${DO_NADA}
.endif

# --------------------------------------------------------------------------
# --  Miscellaneous
# --------------------------------------------------------------------------

# Macro for doing in-place file editing using regexps
REINPLACE_ARGS?=	-i.bak
REINPLACE_CMD?=		${SED} ${REINPLACE_ARGS}
PLIST_SUB+=		OPSYS=${OPSYS}

.include "/xports/Mk/raven.sequence.mk"
