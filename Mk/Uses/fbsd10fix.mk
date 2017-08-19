# Automatically corrects ancient configure and libtool scripts so that
# FreeBSD 10+ is not treated like FreeBSD 1.x, FreeBSD 2.x, etc.
#
# Feature:	fbsd10fix
# Usage:	USES=fbsd10fix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_FBSD10FIX_MK)
_INCLUDE_USES_FBSD10FIX_MK=	yes

.  if "${OPSYS}" == "FreeBSD"
_USES_configure+=        425:freebsd10fix
.  endif

freebsd10fix:
	@${ECHO_MSG} "===>  Autofix configure and libtool scripts for FreeBSD 10+"
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
		${SED} -i.fbsd10bak \
			-e 's|freebsd1\*)|freebsd1.\*)|g' \
			-e 's|freebsd\[12\]\*)|freebsd[12].*)|g' \
			-e 's|freebsd\[123\]\*)|freebsd[123].*)|g' \
			-e 's|freebsd\[\[12\]\]\*)|freebsd[[12]].*)|g' \
			-e 's|freebsd\[\[123\]\]\*)|freebsd[[123]].*)|g' \
			$${f} ; \
		${TOUCH} -mr $${f}.fbsd10bak $${f} ; \
		cmp -s $${f}.fbsd10bak $${f} || ${ECHO_MSG} "===>       applied to $${f}"; \
		cmp -s $${f}.fbsd10bak $${f} && ${RM} $${f}.fbsd10bak ; \
	done || ${TRUE}

.endif	# _INCLUDE_USES_FBSD10FIX_MK
