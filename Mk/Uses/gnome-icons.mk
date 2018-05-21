# Handles gnome icon installation by adding to package manifest
#
# If a GTK+ port installs Freedesktop-style icons toIf a GTK+ port installs
# Freedesktop-style icons to  ${LOCALBASE}/share/icons, then you should use
# this module which ensures that icons are cached and will display properly.
# The module is not for QT-based applications.
#
# Feature:	gnome-icons
# Usage:	USES=gnome-icons
# Valid ARGS:	subpackage
#
# ravenadm will add gtk-update-icon-cache to RUN_DEPENDS
#

.if !defined(_INCLUDE_USES_GNOMEICONS_MK)
_INCLUDE_USES_GNOMEICONS_MK=	yes

_USES_install+=	780:gnome-post-icons

.  if !target(gnome-post-icons)
gnome-post-icons:
	@splist="${WRKDIR}/.manifest.${gnome-icons_ARGS}.mktmp"; \
	if [ -f "$${splist}" ]; then \
	  ${RM} $${splist}.icons1; \
	  for i in `${GREP} "^share/icons/.*/" $${splist} | ${CUT} -d / -f 1-3 | ${SORT} -u`; do \
	    echo "@rmtry $${i}/icon-theme.cache" >> $${splist}.icons1; \
	    echo "@postexec ${LOCALBASE}/bin/gtk-update-icon-cache -q -f %D/$${i} 2>/dev/null || true"   >> $${splist}; \
	    echo "@postunexec ${LOCALBASE}/bin/gtk-update-icon-cache -q -f %D/$${i} 2>/dev/null || true" >> $${splist}; \
	  done; \
	  if [ -f $${splist}.icons1 ]; then \
	    ${CAT} $${splist}.icons1 $${splist} > $${splist}.icons2; \
	    ${RM}  $${splist}.icons1; \
	    ${MV} -f $${splist}.icons2 $${splist}; \
	  fi; \
	fi
.  endif

.endif	# _INCLUDE_USES_GNOMEICONS_MK
