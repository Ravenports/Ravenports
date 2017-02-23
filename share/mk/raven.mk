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
WRKDIR=			${WRKDIRPREFIX}/${NAMEBASE}
SCRIPTSDIR=		${RAVENBASE}/share/mk/Scripts

.if defined(DIST_SUBDIR)
_DISTDIR=		${DISTDIR}
.else
_DISTDIR=		${DISTDIR}/${DIST_SUBDIR}
.endif
_DISTINFO_FILE=		${.CURDIR}/distinfo

# --------------------------------------------------------------------------
# --  Debugging
# --------------------------------------------------------------------------

# How to do nothing.  Override to make it do nothing differently
DO_NADA?=		${TRUE}

# --------------------------------------------------------------------------
# --  Phase: Fetch
# --------------------------------------------------------------------------

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

_DO_FETCH_ENV= 		dp_DISTDIR='${_DISTDIR}' \
			dp_DISTINFO_FILE='${_DISTINFO_FILE}' \
			dp_DIST_SUBDIR='${DIST_SUBDIR}' \
			dp_ECHO_MSG='${ECHO_MSG}' \
			dp_FETCH_CMD='${FETCH_CMD}' \
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

.if !target(fetch)
fetch: do-fetch		# add sequence TODO
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

.if !target(do-extract)
do-extract:
	@for N in ${EXTRACT_ONLY}; do \
		if ! (cd ${EXTRACT_WRKDIR} && ${EXTRACT_HEAD_${N}} ${_DISTDIR}/${DISTFILE_${N}} ${EXTRACT_TAIL_${N}}); \
		then \
			exit 1; \
		fi; \
	done
	${CHMOD} -R ug-s ${WRKDIR}
	${CHOWN} -R 0:0 ${WRKDIR}
.endif
