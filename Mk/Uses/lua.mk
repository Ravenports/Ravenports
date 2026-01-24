# Provide support for lua
#
# Feature:	lua
# Usage:	USES=lua
# Valid ARGS:	[version],[build,run,buildrun],[tools] (version 5.4 implicit), (build implicit)

# ------------------------------------------------------
# Incorporated in ravenadm
# ------------------------------------------------------
# BUILD_DEPENDS=        luaXX:dev:std
# RUN_DEPENDS=          luaXX:primary:std
# BUILDRUN_DEPENDS=	luaXX:dev:std + luaXX:primary:std
# If tools set:
# BUILD_DEPENDS=	luaXX:tools:std
# ------------------------------------------------------

.if !defined(_INCLUDE_USES_LUA_MK)
_INCLUDE_USES_LUA_MK=	yes

.  if ${lua_ARGS:M5.2}
LUA_VER=	5.2
.  elif ${lua_ARGS:M5.3}
LUA_VER=	5.3
.  elif ${lua_ARGS:M5.4}
LUA_VER=	5.4
.  elif ${lua_ARGS:M5.5}
LUA_VER=	5.5
.  else
LUA_VER=	${LUA_DEFAULT}
.endif

# ------------------------------------------------------------------------
# Exported variables
# ------------------------------------------------------------------------
LUA_VER_STR=		${LUA_VER:S/.//}
LUA_VER_FULL=		${LUA_${LUA_VER}_VERSION}
LUA_CMD=		lua${LUA_VER_STR}
LUAC_CMD=		luac${LUA_VER_STR}
LUA_INCDIR=		${LOCALBASE}/include/lua${LUA_VER_STR}
LUA_MODLIBDIR=		${LOCALBASE}/lib/lua/${LUA_VER}
LUA_MODSHAREDIR=	${LOCALBASE}/share/lua/${LUA_VER}
LUA_LIBDIR=		${LOCALBASE}/lib

PLIST_SUB+=	LUA_MODLIBDIR=${LUA_MODLIBDIR:S,^${LOCALBASE}/,,} \
		LUA_MODSHAREDIR=${LUA_MODSHAREDIR:S,^${LOCALBASE}/,,} \
		LUA_VER=${LUA_VER} \
		LUA_INCDIR=${LUA_INCDIR:S,^${LOCALBASE}/,,} \
		LUA_LIBDIR=${LUA_LIBDIR:S,^${LOCALBASE}/,,} \
		LUA_VER_STR=${LUA_VER_STR}
MAKE_ENV+=	LUA_MODLIBDIR=${LUA_MODLIBDIR} \
		LUA_MODSHAREDIR=${LUA_MODSHAREDIR} \
		LUA_VER=${LUA_VER} \
		LUA_INCDIR=${LUA_INCDIR} \
		LUA_LIBDIR=${LUA_LIBDIR}

.endif	# _INCLUDE_USES_LUA_MK
