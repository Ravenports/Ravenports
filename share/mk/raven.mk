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

.include "${RAVENBASE}/share/mk/raven.commands.mk"

NAMEBASE?=		undefined	# dummy, must be defined by port makefile
VARIANT?=		standard	# must be defined by raven tool
TWO_PART_ID=		${NAMEBASE}-${VARIANT}
PKGNAMEBASE=		${NAMEBASE}__${VARIANT}
DISTNAME=		${NAMEBASE}-${DISTVER_PREFIX}${VERSION}${DISTVER_SUFFIX}
WRKDIR=			${WRKDIRPREFIX}/${NAMEBASE}
SCRIPTSDIR=		${RAVENBASE}/share/mk/Scripts

.if defined(DIST_SUBDIR)
_DISTDIR=		${DISTDIR}/${DIST_SUBDIR}
.else
_DISTDIR=		${DISTDIR}
.endif
_DISTINFO_FILE=		${.CURDIR}/distinfo

.if defined(USE_GITHUB)
WRKSRC?=		${WRKDIR}/${GH_PROJECT}-${GH_TAGNAME_EXTRACT}
.endif
.if defined(NO_WRKSUBDIR)
WRKSRC?=		${WRKDIR}/${TWO_PART_ID}
EXTRACT_WRKDIR:=	${WRKSRC}
.else
WRKSRC?=		${WRKDIR}/${DISTNAME}
EXTRACT_WRKDIR:=	${WRKDIR}
.endif
.if defined(WRKSRC_SUBDIR)
WRKSRC:=		${WRKSRC}/${WRKSRC_SUBDIR}
.endif

# --------------------------------------------------------------------------
# --  Common Definitions
# --------------------------------------------------------------------------

# These require modification to bmake (which Ravenports have)

.if !defined(OPSYS)
OPSYS=			${.MAKE.OS.NAME}
.endif

.if !defined(OSVERSION)
OSVERSION=		${.MAKE.OS.VERSION}
.endif

.if !defined(OSREL)
OSREL=			${.MAKE.OS.RELEASE}
.endif

.if !defined(ARCH)
ARCH=			${.MAKE.OS.ARCHITECTURE}
.endif

# --------------------------------------------------------------------------
# --  Debugging
# --------------------------------------------------------------------------

# How to do nothing.  Override to make it do nothing differently
DO_NADA?=		${TRUE}

# --------------------------------------------------------------------------
# --  Phase: Fetch
# --------------------------------------------------------------------------

FETCH_REGET?=		1
FETCH_ENV=		SSL_NO_VERIFY_PEER=1 SSL_NO_VERIFY_HOSTNAME=1

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

_DO_FETCH_ENV= 		dp_DISTDIR='${_DISTDIR}' \
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
			dp_SCRIPTSDIR='${SCRIPTSDIR}' \
			dp_TARGET='${.TARGET}' \
			# end

.if !target(do-fetch)
do-fetch:
.  if !empty(_DISTFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_DL_SITES_ENV} \
		${SH} ${SCRIPTSDIR}/do-fetch.sh ${_DISTFILES:C/.*/'&'/}
.  endif
.  if !empty(_PATCHFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_PATCH_SITES_ENV} \
		${SH} ${SCRIPTSDIR}/do-fetch.sh ${_PATCHFILES:C/:-p[0-9]//:C/.*/'&'/}
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
		dp_DISTDIR='${_DISTDIR}' \
		dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
		dp_DIST_SUBDIR='${DIST_SUBDIR}' \
		dp_ECHO_MSG='${ECHO_MSG}' \
		dp_FETCH_REGET='${FETCH_REGET}' \
		dp_MAKE='${MAKE}' \
		dp_MAKEFLAGS='${.MAKEFLAGS}' \
		dp_SCRIPTSDIR='${SCRIPTSDIR}' \
		dp_DISABLE_SIZE= \
		dp_DISABLE_CHECKSUM= \
		${SH} ${SCRIPTSDIR}/checksum.sh ${_CKSUMFILES:C/.*/'&'/}
.  endif
.endif

# --------------------------------------------------------------------------
# --  Makesum (developer)
# --------------------------------------------------------------------------

.if !target(makesum)
makesum:
.  if !empty(_DISTFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_MASTER_SITES_ENV} \
		dp_DISABLE_CHECKSUM=yes \
		dp_DISABLE_SIZE=yes \
		${SH} ${SCRIPTSDIR}/do-fetch.sh ${_DISTFILES:C/.*/'&'/}
.  endif
.  if !empty(PATCHFILES)
	@${SETENV} \
		${_DO_FETCH_ENV} ${_PATCH_SITES_ENV} \
		dp_DISABLE_CHECKSUM=yes \
		dp_DISABLE_SIZE=yes \
		${SH} ${SCRIPTSDIR}/do-fetch.sh ${_PATCHFILES:C/:-p[0-9]//:C/.*/'&'/}
.  endif
	@${SETENV} \
		${_CHECKSUM_INIT_ENV} \
		dp_CHECKSUM_ALGORITHMS='SHA256' \
		dp_CKSUMFILES='${_CKSUMFILES}' \
		dp_DISTDIR='${_DISTDIR}' \
		dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
		dp_ECHO_MSG='${ECHO_MSG}' \
		dp_SCRIPTSDIR='${SCRIPTSDIR}' \
		${SH} ${SCRIPTSDIR}/makesum.sh ${_DISTFILES:C/.*/'&'/}
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

${EXTRACT_WRKDIR}:
	@${MKDIR} ${.TARGET}

extract-message:
	@${ECHO_MSG} "===>  Extracting for ${TWO_PART_ID}"

.if !target(do-extract)
do-extract: ${EXTRACT_WRKDIR}
.  for N in ${EXTRACT_ONLY}
	@if ! (cd ${EXTRACT_WRKDIR} && ${EXTRACT_HEAD_${N}} ${_DISTDIR}/${DISTFILE_${N}:C/:.*//} ${EXTRACT_TAIL_${N}}); \
	then \
		exit 1; \
	fi
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
PATCH_DIST_ARGS=	--suffix .bak.orig -E ${PATCH_DIST_STRIP} --batch
.else
PATCH_ARGS=		--forward --quiet -E ${PATCH_STRIP} --batch
PATCH_DIST_ARGS=	--suffix .bak.orig --forward --quiet -E ${PATCH_DIST_STRIP} --batch
.endif

patch-message:
	@${ECHO_MSG} "===>  Patching for ${TWO_PART_ID}"

.if !target(do-patch)
do-patch:
	@${SETENV} \
		dp_BZCAT="${BZCAT}" \
		dp_CAT="${CAT}" \
		dp_DISTDIR="${_DISTDIR}" \
		dp_ECHO_MSG="${ECHO_MSG}" \
		dp_GZCAT="${GZCAT}" \
		dp_OPSYS="${OPSYS}" \
		dp_PATCH="${PATCH}" \
		dp_PATCHDIR="${.CURDIR}/patches" \
		dp_OPSYS_PATCHDIR="${.CURDIR}/opsys" \
		dp_PATCHFILES="${_PATCHFILES:C/:.*//}" \
		dp_PATCH_ARGS=${PATCH_ARGS:Q} \
		dp_PATCH_DEBUG_TMP="${PATCH_DEBUG:Dyes}" \
		dp_PATCH_DIST_ARGS="${PATCH_DIST_ARGS}" \
		dp_PATCH_SILENT="yes" \
		dp_PATCH_WRKSRC=${PATCH_WRKSRC} \
		dp_PORTID="${TWO_PART_ID}" \
		dp_SCRIPTSDIR="${SCRIPTSDIR}" \
		dp_UNZIP_CMD="${UNZIP_CMD}" \
		dp_XZCAT="${XZCAT}" \
		${SH} ${SCRIPTSDIR}/do-patch.sh
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

.include "${RAVENBASE}/share/mk/raven.sequence.mk"
