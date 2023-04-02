# Automatically adds MidnightBSD support to GNU autotools scripts.
#
# Feature:	mbsdfix
# Usage:	USES=mbsdfix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_MBSDFIX_MK)
_INCLUDE_USES_MBSDFIX_MK=	yes

.  if "${OPSYS}" == "MidnightBSD"
_USES_configure+=        426:midnightfix
.  endif

midnightfix:
	@${ECHO_MSG} "===>  Autofix configure and libtool scripts for MidnightBSD"
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
		${SED} -i.mbsdbak \
			-e 's#freebsd\* | dragonfly\*)#freebsd* | dragonfly* | midnight*)#g' \
			-e 's#freebsd\* | kfreebsd\*-gnu | dragonfly\*)#freebsd* | dragonfly* | midnight*)#g' \
			-e 's#freebsd\* | kfreebsd\*-gnu)#freebsd* | dragonfly* | midnight*)#g' \
			$${f} ; \
		${TOUCH} -mr $${f}.mbsdbak $${f} ; \
		cmp -s $${f}.mbsdbak $${f} || ${ECHO_MSG} "===>       applied to $${f}"; \
		cmp -s $${f}.mbsdbak $${f} && ${RM} $${f}.mbsdbak ; \
	done || ${TRUE}

.endif	# _INCLUDE_USES_MBSDFIX_MK
