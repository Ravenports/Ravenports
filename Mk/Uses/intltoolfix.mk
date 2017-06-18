# Adjust configure for intltool (hack)
#
# Feature:	intltoolfix
# Usage:	USES=intltoolfix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_INTLTOOLFIX_MK)
_INCLUDE_USES_INTLTOOLFIX_MK=	yes

_USES_extract+=	855:intlhack

.  if !target(intlhack)
intlhack:
	${FIND} ${WRKSRC} -name "intltool-merge.in" | \
	    ${XARGS} ${REINPLACE_CMD} \
		's|mkdir $$lang or|mkdir $$lang, 0777 or| ; \
		 s|^push @INC, "/.*|push @INC, "${LOCALBASE}/share/intltool";| ; \
		 s|/usr/bin/iconv|${ICONV_CMD}|g ; \
		 s|unpack *[(]'"'"'U\*'"'"'|unpack ('"'"'C*'"'"'|'
	${FIND} ${WRKSRC} -name configure | \
	    ${XARGS} ${REINPLACE_CMD} \
		's/DATADIRNAME=lib/DATADIRNAME=share/'
.  endif

.endif	# _INCLUDE_USES_INTLTOOLFIX_MK
