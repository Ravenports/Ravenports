# Replace #! interpreters in scripts by what we actually have.
#
# Standard templates for bash, perl, python,... are included out of
# the box, others can easily be added per port.
#
# Feature:	shebangfix
# Usage:	USES=shebangfix
#
#   SHEBANG_REGEX	a regular expression to match files that needs to be converted
#   SHEBANG_FILES	list of files or glob pattern relative to ${WRKSRC} (or ${WRKDIR})
#   SHEBANG_GLOB	list of glob pattern find(1) will match with
#   SHEBANG_ADD_SH	list of files or glob pattern to prefix found files
#                       with "#!/bin/sh"\n\n"
#
# To specify that ${WRKSRC}/path1/file and all .pl files in ${WRKSRC}/path2
# should be processed:
#
#   SHEBANG_FILES=	path1/file path2/*.pl
#
# To define custom shebangs to replace, use the following (note that
# shebangs with spaces should be quoted):
#
#   SHEBANG_OLD_PERL=	/usr/bin/perl5.005 "/usr/bin/setenv perl5.005"
#
# To define a new shebang scheme add the following to the port Makefile:
#
#   SHEBANG_LANG=	lua
#   SHEBANG_OLD_LUA=	/usr/bin/lua
#   SHEBANG_NEW_LUA=	${LOCALBASE}/bin/lua
#
# To override a definition, for example replacing /usr/bin/perl by
# /usr/bin/env perl, add the following:
#
#   SHEBANG_NEW_PERL=	${SETENV} perl
#

.if !defined(_INCLUDE_USES_SHEBANGFIX_MK)
_INCLUDE_USES_SHEBANGFIX_MK=	yes

SHEBANG_LANG+=	bash java ksh perl php python ruby tcl tk lua r

.  if ${USES:Mlua*}
SHEBANG_NEW_LUA?=	${LOCALBASE}/bin/${LUA_CMD}
.else
SHEBANG_NEW_LUA?=	${LOCALBASE}/bin/lua${LUA_DEFAULT:S/.//}
.  endif

SHEBANG_OLD_TCL+=	/usr/bin/tclsh
SHEBANG_NEW_TCL?=	${TCLSH}

SHEBANG_OLD_TK+=	/usr/bin/wish
SHEBANG_NEW_TK?=	${WISH}

.  if ${USES:Mpython*}
SHEBANG_NEW_PYTHON?=	${PYTHON_CMD}
.  else
SHEBANG_NEW_PYTHON?=	${LOCALBASE}/bin/python${PYTHON3_DEFAULT}
.  endif

# Replace the same patterns for all langs and setup a default, that may have
# been set already above with ?=.
.  for lang in ${SHEBANG_LANG}
SHEBANG_NEW_${lang:tu}?= ${LOCALBASE}/bin/${lang}
SHEBANG_OLD_${lang:tu}+= "/usr/bin/env ${lang}"
SHEBANG_OLD_${lang:tu}+= /bin/${lang}
SHEBANG_OLD_${lang:tu}+= /usr/bin/${lang}
.  endfor

# Additional old patterns for python3
SHEBANG_OLD_PYTHON+=	"/usr/bin/env python3"
SHEBANG_OLD_PYTHON+=	/bin/python3
SHEBANG_OLD_PYTHON+=	/usr/bin/python3

.  for lang in ${SHEBANG_LANG}
.    for old_cmd in ${SHEBANG_OLD_${lang:tu}}
_SHEBANG_REINPLACE_ARGS+= -e "1s|^\#![[:space:]]*${old_cmd:C/\"//g}\([[:space:]]\)|\#!${SHEBANG_NEW_${lang:tu}}\1|"
_SHEBANG_REINPLACE_ARGS+= -e "1s|^\#![[:space:]]*${old_cmd:C/\"//g}$$|\#!${SHEBANG_NEW_${lang:tu}}|"
.    endfor
.  endfor

.if "${DL_SITES_main:H:H:H}" == "PYPIWHL"
_USES_stage+=	710:fix-shebang
BASESRC=${WRKDIR}
.else
_USES_patch+=	860:fix-shebang
BASESRC=${WRKSRC}
.endif

fix-shebang:
	@${ECHO_MSG} "====> Invoking shebangfix"
.  if defined(SHEBANG_REGEX)
	@cd ${BASESRC}; \
		${FIND} . -type f -iregex '${SHEBANG_REGEX}' \
		-exec ${SED} -i'' ${_SHEBANG_REINPLACE_ARGS} {} +
.  endif
.  if defined(SHEBANG_GLOB)
.    for f in ${SHEBANG_GLOB}
	@cd ${BASESRC}; \
		${FIND} . -type f -name '${f}' \
		-exec ${SED} -i'' ${_SHEBANG_REINPLACE_ARGS} {} +
.    endfor
.  endif
.  if defined(SHEBANG_FILES)
	@(cd ${BASESRC} && \
		${ECHO_CMD} ${SHEBANG_FILES} | \
		${XARGS} ${SED} -i'' ${_SHEBANG_REINPLACE_ARGS})
.  endif
.  if defined(SHEBANG_ADD_SH)
.    for f in ${SHEBANG_ADD_SH}
	@${ECHO_MSG} "      Add shebang to $f"
	@cd ${BASESRC} && ${SED} -i'' '1s|^|#!/bin/sh\n\n|' '${f}'
.    endfor
.  endif

.endif
