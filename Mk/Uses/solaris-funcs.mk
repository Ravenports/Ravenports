# On a per file basis, insert static functions to source to allow
# building on old solaris 10.
# Supports
#  - asprintf/vasprintf
#  - mkdtemp
#  - dirfd
#  - strnlen
#  - strndup
#  - strsep
#  - getline
#  - timegm
#  - <err.h>
#
# Feature:     solaris-funcs
# Usage:       USES=solaris-funcs
# Valid ARGS:  none
#
# Used in conjunction with the following KEYWORDS
#
# SOL_FUNCTIONS      Format: function:path-to-file
#                    The path starts at $WRKSRC
#

.if !defined(_INCLUDE_USES_SOLFUNC_MK)
_INCLUDE_USES_SOLFUNC_MK=	yes

.  if "${OPSYS}" == "SunOS"
_USES_extract+=        810:insertsolfunc
.  endif

SOL_FUNC_ASPRINTF=	${SOL_FUNCTIONS:Masprintf\:*:C/.*://:O:u}
SOL_FUNC_MKDTEMP=	${SOL_FUNCTIONS:Mmkdtemp\:*:C/.*://:O:u}
SOL_FUNC_DIRFD=		${SOL_FUNCTIONS:Mdirfd\:*:C/.*://:O:u}
SOL_FUNC_STRNLEN=	${SOL_FUNCTIONS:Mstrnlen\:*:C/.*://:O:u}
SOL_FUNC_STRNDUP=	${SOL_FUNCTIONS:Mstrndup\:*:C/.*://:O:u}
SOL_FUNC_STRSEP=	${SOL_FUNCTIONS:Mstrsep\:*:C/.*://:O:u}
SOL_FUNC_GETLINE=	${SOL_FUNCTIONS:Mgetline\:*:C/.*://:O:u}
SOL_FUNC_ERR_H=		${SOL_FUNCTIONS:Merr.h\:*:C/.*://:O:u}
SOL_FUNC_TIMEGM=	${SOL_FUNCTIONS:Mtimegm\:*:C/.*://:O:u}
SOL_UNIQUE=		${SOL_FUNCTIONS:Nerr.h\:*:C/.*://:O:u}

insertsolfunc:
	@${ECHO_MSG} "===>  Add static functions for solaris 10"
.for F in ${SOL_UNIQUE}
	@if [ -f "${WRKSRC}/${F}" ]; then \
	  ${MV} ${WRKSRC}/${F} ${WRKSRC}/${F}.solfunc ;\
	else \
          ${ECHO_MSG} "solaris-func issue: ${F} does not exist." ;\
	fi
.endfor
.for F in ${SOL_FUNC_ASPRINTF}
	@${ECHO_MSG} "====>  Insert asprint/vasprint to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh asprintf >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_MKDTEMP}
	@${ECHO_MSG} "====>  Insert mkdtemp to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh mkdtemp >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_DIRFD}
	@${ECHO_MSG} "====>  Insert dirfd to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh dirfd >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_STRNLEN}
	@${ECHO_MSG} "====>  Insert strnlen to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh strnlen >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_STRNDUP}
	@${ECHO_MSG} "====>  Insert strndup to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh strndup >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_STRSEP}
	@${ECHO_MSG} "====>  Insert strsep to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh strsep >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_GETLINE}
	@${ECHO_MSG} "====>  Insert getline to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh getline >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_TIMEGM}
	@${ECHO_MSG} "====>  Insert timegm to ${F}"
	@${MK_SCRIPTS}/solaris-funcs.sh timegm >> ${WRKSRC}/${F}
.endfor
.for F in ${SOL_FUNC_ERR_H}
	@${ECHO_MSG} "====>  Install ${F} header "
	@${MK_SCRIPTS}/solaris-funcs.sh err.h > ${WRKSRC}/${F}
.endfor

.for F in ${SOL_UNIQUE}
	@${CAT} ${WRKSRC}/${F}.solfunc >> ${WRKSRC}/${F}
.endfor

.endif	# _INCLUDE_USES_SOLFUNC_MK
