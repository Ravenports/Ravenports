# Facilitate SMF support on Solaris-based distributions
#
# Feature:      smf
# Usage:        USES=smf
# Valid ARGS:   name of subpackage
#
# SMF_PREFIX
#   This is the global FMRI prefix that will be used in SMF.  The
#   default value is "ravenports", so the general URI will be of
#   the form "svc:/ravenports/<package>:<instance>".
#   This is immutable.
#
# SMF_NAME
#  This sets the service name part of the FMRI, and defaults to the
#  lower-case string of NAMEBASE.
#
# SMF_METHODS
#  This is a list of defined methods to install.
#  They will be located at $WRKDIR, which means they are generated
#  by SUB_FILES regardless if there are substitutions or not.


.if !defined(_INCLUDE_USES_SMF_MK)
_INCLUDE_USES_SMF_MK=	yes

SMF_PREFIX?=			ravenports

# Directory to hold the SMF manifest/method files
SMF_DIR?=			lib/svc
SMF_MANIFEST_DIR?=		${SMF_DIR}/manifest
SMF_METHOD_DIR?=		${SMF_DIR}/method

SMF_NAME?=			${NAMEBASE:tl}
SMF_MANIFEST_FILE?=		${SMF_MANIFEST_DIR}/${SMF_NAME}.xml
SMF_METHODS?=			# no defined methods

PLIST_SUB+=			SMF_NAME=${SMF_NAME}
PLIST_SUB+=			SMF_PREFIX=${SMF_PREFIX}
SUB_LIST+=			SMF_NAME=${SMF_NAME}
SUB_LIST+=			SMF_PREFIX=${SMF_PREFIX}

.  if "${OPSYS}" == "SunOS"
_USES_patch+=        855:tag_smf
_USES_install+=      715:install_manifest
.  endif

tag_smf:
	@${ECHO_MSG} "===>  Mark SMF module for SunOS"
	${TOUCH} "/tmp/.smf.present"

install_manifest:
	${MKDIR} ${STAGEDIR}${PREFIX}/${SMF_MANIFEST_DIR}
	${INSTALL_DATA} ${WRKDIR}/manifest.xml ${STAGEDIR}${PREFIX}/${SMF_MANIFEST_FILE}
	${ECHO} "@smf ${SMF_MANIFEST_FILE}" >> ${WRKDIR}/.manifest.${smf_ARGS}.mktmp
.for method in ${SMF_METHODS}
	${MKDIR} ${STAGEDIR}${PREFIX}/${SMF_METHOD_DIR}
	${INSTALL_SCRIPT} ${WRKDIR}/${method} ${STAGEDIR}${PREFIX}/${SMF_METHOD_DIR}/
	${ECHO} "${SMF_METHOD_DIR}/${method}" >> ${WRKDIR}/.manifest.${smf_ARGS}.mktmp
.endfor


.endif	# _INCLUDE_USES_SMF_MK
