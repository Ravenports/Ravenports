# Handle gnu configure that does not properly support DESTDIR
#
# Feature:	destdirfix
# Usage:	USES=destdirfix
# Valid ARGS:	none

.if !defined(_INCLUDE_USES_DESTHACK_MK)
_INCLUDE_USES_DESTHACK_MK=	yes

GNU_CONFIGURE_PREFIX=	\$${${DESTDIRNAME}}${PREFIX}
GNU_CONFIGURE_MANPREFIX=	\$${${DESTDIRNAME}}${MANPREFIX}

.endif
