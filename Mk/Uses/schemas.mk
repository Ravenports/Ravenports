# Handles gnome schemas (glib and gconf) by adding to package manifest
#
# Feature:	schemas
# Usage:	USES=schemas
# Valid ARGS:	subpackage
#
# GCONF_SCHEMAS	Set the following to list of all the gconf schema files that
#		your port installs. These schema files and %gconf.xml files
#		will be automatically added to the subpackage manifest. For
#		example, if your port has "etc/gconf/schemas/(foo.schemas
#		and bar.schemas)", add the following to your Makefile:
#		"GCONF_SCHEMAS=foo.schemas bar.schemas".
#
# GLIB_SCHEMAS	Set the following to list of all gsettings schema files
#		(*.gschema.xml) that your ports installs. The schema files
#		will be automatically added to the subpackage manifest. For
#		example, if your port has
#		"share/glib-2.0/schemas/(foo.gschema.xml and bar.gschema.xml)",
#		add the following to your Makefile:
#		"GLIB_SCHEMAS=foo.gschema.xml bar.gschema.xml".
#
# GCONF_CONFIG_OPTIONS		Used by GCONF_SCHEMAS
# GCONF_CONFIG_DIRECTORY	Used by GCONF_SCHEMAS
#
# ravenadm will add glib to RUN_DEPENDS
#

.if !defined(_INCLUDE_USES_SCHEMAS_MK)
_INCLUDE_USES_SCHEMAS_MK=	yes

.  if defined(GLIB_SCHEMAS)

_USES_install+=	780:gnome-post-glib-schemas

.    if !target(gnome-post-glib-schemas)
gnome-post-glib-schemas:
	@splist="${WRKDIR}/.manifest.${schemas_ARGS}.mktmp"; \
	if [ -f "$${splist}" ]; then \
          echo "... install gnome library schemas"; \
	  for i in ${GLIB_SCHEMAS}; do \
	    echo "share/glib-2.0/schemas/$${i}" >> $${splist}; \
	  done; \
	fi
.    endif
.  endif	# GLIB_SCHEMAS

.  if defined(GCONF_SCHEMAS)
_USES_install+=	780:gnome-post-gconf-schemas

GCONF_CONFIG_OPTIONS?=		merged
GCONF_CONFIG_DIRECTORY?=	etc/gconf/gconf.xml.defaults
MAKE_ENV+=			GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL=1

.    if !target(gnome-post-gconf-schemas)
gnome-post-gconf-schemas:
	@splist="${WRKDIR}/.manifest.${schemas_ARGS}.mktmp"; \
	if [ -f "$${splist}" ]; then \
          echo "... install gnome configuration schemas"; \
	  for i in ${GCONF_SCHEMAS}; do \
		${SH} ${MK_SCRIPTS}/schema_heredoc.sh schema \
		  "${_SCRIPT_FILE}.${schemas_ARGS}" "${GCONF_CONFIG_OPTIONS}" \
		  "${GCONF_CONFIG_DIRECTORY}" "${WRKSRC}" $$i ;\
		echo "etc/gconf/schemas/$${i}" >> $${splist}; \
	  done; \
	  ${SH} ${MK_SCRIPTS}/schema_heredoc.sh finalize "${_SCRIPT_FILE}.${schemas_ARGS}";\
        fi
.    endif
.  endif	# GCONF_SCHEMAS

.endif	# _INCLUDE_USES_SCHEMAS_MK
