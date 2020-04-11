# Provide support to generate gtk documentation and relocate 
# them later to the standard documentation directory
#
# Feature:		gtk-doc
# Usage:		USES=gtk-doc
# Arguments:		none
#

.if !defined(_INCLUDE_USES_GTKDOC_MK)
_INCLUDE_USES_GTKDOC_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	gtk-doc:single:standard
# -----------------------------------------------

GTKDOC_OUTPUT_BASEDIR?=	${NAMEBASE}
GTKDOC_INTERMED_DIR?=	html/
GTKDOC_PRODUCTS=	share/gtk-doc/${GTKDOC_INTERMED_DIR}${GTKDOC_OUTPUT_BASEDIR}

_USES_install+= 845:relocate-gtk-docs

.  if !target(relocate-gtk-docs)
relocate-gtk-docs:
	@if [ ! -d "${STAGEDIR}${PREFIX}/${GTKDOC_PRODUCTS}" ]; then\
          echo "## warning ## gtk-doc output directory does not exist! (${PREFIX}/${GTKDOC_PRODUCTS})";\
	else \
	  ${MKDIR} ${STAGEDIR}${STD_DOCDIR:H};\
	  ${MV} ${STAGEDIR}${PREFIX}/${GTKDOC_PRODUCTS} ${STAGEDIR}${STD_DOCDIR};\
	  ${RM} -r ${STAGEDIR}${PREFIX}/share/gtk-doc;\
	  echo "====> gtk-docs relocated to ${STD_DOCDIR}";\
	fi
.  endif

.endif
