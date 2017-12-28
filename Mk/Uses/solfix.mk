# Automatically corrects ancient configure and libtool scripts so that
# triplet i?86-*-solaris* is converted to x86_64-*-solaris*
#
# Feature:	solfix
# Usage:	USES=solfix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_SOLFIX_MK)
_INCLUDE_USES_SOLFIX_MK=	yes

.  if "${OPSYS}" == "SunOS"
_USES_configure+=        425:suntargetfix
.  endif

suntargetfix:
	@${ECHO_MSG} "===>  Autofix configure and libtool scripts for Solaris"
	@for f in `${FIND} ${WRKDIR} -type f \( \
		-name config.libpath -o \
		-name config.rpath -o \
		-name configure -o \
		-name libtool.m4 -o \
		-name ltconfig -o \
		-name libtool -o \
		-name aclocal.m4 -o \
		-name acinclude.m4 \)` ; \
	do \
		${SED} -i.sunbak \
			-e 's|i.86-\*-solaris\*)|x86_64-\*-solaris\*)|g' \
			$${f} ; \
		${TOUCH} -mr $${f}.sunbak $${f} ; \
		cmp -s $${f}.sunbak $${f} || ${ECHO_MSG} "===>       applied to $${f}"; \
		cmp -s $${f}.sunbak $${f} && ${RM} $${f}.sunbak ; \
	done || ${TRUE}

.endif	# _INCLUDE_USES_SOLFIX_MK
