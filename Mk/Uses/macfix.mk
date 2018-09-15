# Automatically update scripts to make MacOS have the same library
# symlinks as their posix contemporaries
#
# Feature:	macfix
# Usage:	USES=macfix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_MACFIX_MK)
_INCLUDE_USES_MACFIX_MK=	yes

.  if "${OPSYS}" == "Darwin"
_USES_configure+=        425:mactargetfix
.  endif

mactargetfix:
	@${ECHO_MSG} "===>  Autofix configure for MacOS/Darwin"
	@for f in `${FIND} ${WRKSRC} -name configure`; do \
	${SED} -i.macbak \
	-e "/library_names_spec='.libname.release.major.shared_ext .libname.shared_ext'/\
	s|spec='|spec='\$$libname\$$release\$$versuffix\$$shared_ext |" \
	-e "/library_names_spec='.{libname}.{release}.{major}.shared_ext .{libname}.shared_ext'/\
	s|spec='|spec='\$$libname\$$release\$$versuffix\$$shared_ext |" \
	$$f ; done || ${TRUE}

.endif	# _INCLUDE_USES_MACFIX_MK
