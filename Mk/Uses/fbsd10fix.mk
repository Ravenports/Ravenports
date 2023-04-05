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
	${TOUCH} "${WRKDIR}/.fbsd10fix.exec"
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
			$${f} ;\
		${TOUCH} -mr $${f}.fbsd10bak $${f} ;\
		if cmp -s "$${f}.fbsd10bak" "$${f}";\
		then \
			${RM} "$${f}.fbsd10bak" ;\
		else \
			${ECHO_MSG} "===>       applied to $${f}" ;\
			${ECHO} "$${f}" >> "${WRKDIR}/.fbsd10fix.success" ;\
		fi ;\
	done || ${TRUE}

.endif	# _INCLUDE_USES_FBSD10FIX_MK
