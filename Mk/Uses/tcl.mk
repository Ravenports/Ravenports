# Provide support for Tcl/Tk
#
# Feature:	tcl
# Usage:	USES=tcl
# Valid ARGS:	[version],[build,run],tea,tk
#               (version 8.6 implicit), (buildrun implicit)

.if !defined(_INCLUDE_USES_TCL_MK)
_INCLUDE_USES_TCL_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if {tcl_ARGS:Mbuild}
#  .if {tcl_ARGS:Mtk}
#     BUILD_DEPENDS+=    tk:dev:standard   (pulls in tcl:dev)
#     BUILD_DEPENDS+=    tk:tools:standard (pulls in tcl:tools)
#  .else
#     BUILD_DEPENDS+=    tcl:dev:standard
#     BUILD_DEPENDS+=    tcl:tools:standard
#  .endif
#.elsif {tcl_ARGS:Mrun}
#  .if {tcl_ARGS:Mtk}
#     RUN_DEPENDS+=      tk:tools (pulls in tcl:tools)
#  .else
#     RUN_DEPENDS+=      tcl:tools
#  .endif
#.else
#  .if {tcl_ARGS:Mtk}
#     BUILD_DEPENDS+=    tk:dev:standard   (pulls in tcl:dev)
#     BUILDRUN_DEPENDS+= tk:tools:standard (pulls in tcl:tools)
#  .else
#     BUILD_DEPENDS+=    tcl:dev:standard
#     BUILDRUN_DEPENDS+= tcl:tools:standard
#  .endif
#.endif
# -----------------------------------------------


.  if ${tcl_ARGS:M8.6}
TCL_VER=	8.6
.  elif ${tcl_ARGS:M8.5}
TCL_VER=	8.5
.  else
TCL_VER=	${TCL_DEFAULT}
.endif

# ------------------------------------------------------------------------
# Exported variables
# ------------------------------------------------------------------------
TCL_VER_FULL=		${TCL_${TCL_VER}_VERSION}
TCL_SHLIB_VER=		${TCL_VER:S/.//g}
TCLSH=			${LOCALBASE}/bin/tclsh${TCL_VER}
TCL_LIBDIR=		${LOCALBASE}/lib/tcl${TCL_VER}
TCL_INCLUDEDIR=		${LOCALBASE}/include/tcl${TCL_VER}

.  if ${tcl_ARGS:Mtk}
TK_VER=			${TCL_VER}
TK_VER_FULL=		${TCL_VER_FULL}
TK_SHLIB_VER=		${TCL_SHLIB_VER}
WISH=			${LOCALBASE}/bin/wish${TK_VER}
TK_LIBDIR=		${LOCALBASE}/lib/tk${TK_VER}
TK_INCLUDEDIR=		${LOCALBASE}/include/tk${TK_VER}
.  endif

.  if ${tcl_ARGS:Mtea}
GNU_CONFIGURE=		yes
TCL_PKG=		${NAMEBASE:C/^tcl(-?)//:C/(-?)tcl\$//}${PORTVERSION}
PLIST_SUB+=		TCL_PKG=${TCL_PKG}
CONFIGURE_ARGS+=	--exec-prefix=${PREFIX} \
			--with-tcl=${TCL_LIBDIR} \
			--with-tclinclude=${TCL_INCLUDEDIR}
.    if ${tcl_ARGS:Mtk}
CONFIGURE_ARGS+=	--with-tk=${TK_LIBDIR} \
			--with-tkinclude=${TK_INCLUDEDIR}
.    endif
.  endif

.endif	# _INCLUDE_USES_TCL_MK
