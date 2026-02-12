# Provide support for Comprehensive R Archive Network (CRAN)
#
# Feature:		cran
# Usage:		USES=cran
# Arguments:		none
#

.if !defined(_INCLUDE_USES_CRAN_MK)
_INCLUDE_USES_CRAN_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	R:primary:std
#                       icu:dev:std
# RUN_DEPENDS+=		R:primary:std
#                       R:nls:std
# Not in RUN_DEPENDS:
#                       R:docs:std
#                       R:man:std
# -----------------------------------------------

RNAMEBASE=		${NAMEBASE:C/^R-//}
R_LIB_DIR=		lib/R/library
R_MOD_DIR?=		${R_LIB_DIR}/${RNAMEBASE}
PLIST_SUB+=		R_MOD_DIR=${R_MOD_DIR}
MAKE_ENV+=		TZ="UTC"

R_COMMAND=		${LOCALBASE}/bin/R

.if !target(do-install)
R_POSTCMD_INSTALL_OPTIONS+=	-l ${STAGEDIR}${PREFIX}/${R_LIB_DIR}
R_POSTCMD_INSTALL_OPTIONS+=	--install-tests

do-build:
	# skip build

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/${R_LIB_DIR}
	(cd ${WRKDIR} && ${SETENVI} ${MAKE_ENV} \
		${R_COMMAND} \
		${R_PRECMD_INSTALL_OPTIONS} CMD INSTALL \
		${R_POSTCMD_INSTALL_OPTIONS} ${RNAMEBASE})

.  if !defined(WITH_DEBUG)
	@flist=$$(${FIND} ${STAGEDIR}/ -type f -perm /111 -print) ;\
	if [ -n "$$flist" ]; then \
	   for f in $$flist; do \
	      (${FILE} $$f | ${GREP} -Fq ", not stripped")\
	      && ${ECHO_CMD} "Auto-stripping $$f"\
              && ${STRIP_CMD} $$f || ${TRUE} ;\
	   done ;\
	fi
.  endif

	@${FIND} ${STAGEDIR}${PREFIX} -type d -empty -delete
.endif


_USES_install+= 951:cran-autoplist

cran-autoplist:
	@if [ ! -d "${MANIFESTDIR}" ]; then \
		echo "====> auto-generating single manifest" ;\
		(cd ${STAGEDIR}${PREFIX} && \
		${FIND} lib sbin bin share \
		\( -type f -o -type l \) 2>/dev/null | ${SORT}) \
		>> ${WRKDIR}/.manifest.single.mktmp ;\
	fi
.endif
