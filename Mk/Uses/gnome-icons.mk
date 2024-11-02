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
# because it comes the trigger to handle icons cache. 
#

.if !defined(_INCLUDE_USES_GNOMEICONS_MK)
_INCLUDE_USES_GNOMEICONS_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${gnome-icons_ARGS:Mbuild}
# RUN_DEPENDS+=	gtk3:icons-cache:std
#.endif
# -----------------------------------------------

.endif	# _INCLUDE_USES_GNOMEICONS_MK
