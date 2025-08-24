# Run autoreconf in AUTORECONF_WRKSRC to update configure, Makefile.in and
# other build scripts.
#
# Autoreconf runs the following commands provided by autoconf and automake.
# Each command applies to a single configure.ac or
# configure.in (old name).  If configure.ac defines subdirectories with their
# own configure.ac (using AC_CONFIG_SUBDIRS), autoreconf will recursively
# update those as well.
#
# aclocal	Looks up definitions of m4 macros used in configure.ac that are
#		not provided by autoconf and copies them from their source *.m4
#		file to aclocal.m4.  Local *.m4 files included with the source
#		code take precedence over systemwide *.m4 files.
# autoconf	Generates configure from configure.ac using macro definitions
#		provided by autoconf itself and aclocal.m4.
# autoheader	Generates a configuration header (typically config.h.in) from
#		configure.ac and the macro definitions in aclocal.m4.  Run by
#		autoreconf if configure.ac (or one of the macros it uses)
#		contains AC_CONFIG_HEADERS, AC_CONFIG_HEADER (undocumented), or
#		AM_CONFIG_HEADER (obsolete).
# automake	Generates Makefile.in from Makefile.am for each Makefile
#		listed in configure.ac (using AC_CONFIG_FILES).  Also updates
#		build scripts like compile, depcomp, install-sh, ylwrap,...
#		Run by autoreconf if configure.ac (or one of the macros it
#		uses) contains AM_INIT_AUTOMAKE.
#
# Autoreconf may also run these additional commands provided by other ports.
# A port needs to have a build dependency on these ports when that's the case.
#
# autopoint	Provided by gettext:bldtools:std.  Updates gettext related *.m4
#		files included with the source code and build scripts such as
#		config.rpath.  Run by autoreconf if configure.ac (or one of the
#		macros it uses) contains AM_GNU_GETTEXT.  A build dependency on
#		can be added with USES+=gettext:build.
#		Note that autoreconf runs autopoint even if a port has an NLS
#		option and the option is disabled.  The build dependency on
#		gettext-tools is not optional.  If the run dependency on
#		gettext is optional this can be specified with
#		NLS_USES=gettext-runtime.
# gtkdocize	Provided by gtk-doc.  Updates gtk-doc related *.m4
#		files included with the source code and build scripts such as
#		gtk-doc.make.  Run by autoreconf if configure.ac contains
#		GTK_DOC_CHECK.  The build dependency can be made with
#		USES=gtkdoc.
# intltoolize	Provided by intltool:primary.  Updates intltool related *.m4
#		files included with the source code and build scripts such as
#		po/Makefile.in.in.  Run by autoreconf if configure.ac contains
#		(AC|IT)_PROG_INTLTOOL.  A build dependency on intltool
#		can be added with GNOME_COMPONENTS+= intltool.
# libtoolize	Provided by libtool.  Updates libtool related *.m4 files
#		included with the source code and build scripts such as
#		ltmain.sh.  Run by autoreconf if configure.ac  (or one of the
#		macros it uses) contains AC_PROG_LIBTOOL or LT_INIT.  A build
#		dependency on libtool is added implicitly when USES
#		contains both autoreconf and libtool.
#
# Feature:	autoreconf
# Usage:	USES=autoreconf or USES=autoreconf:args
# Valid args:	build	Don't run autoreconf, only add build dependencies

.if !defined(_INCLUDE_USES_AUTORECONF_MK)
_INCLUDE_USES_AUTORECONF_MK=	yes

_USES_POST+=	autoreconf

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	autoconf:primary:std
#			automake:primary:std
# if ARGS does not contain "build", then
# BUILD_DEPENDS+=	libtool:primary:std
# -----------------------------------------------

_AUTORECONF?=	2.72
AUTORECONF?=	${LOCALBASE}/bin/autoreconf
AUTORECONF_WRKSRC?=	${WRKSRC}

# In case autoconf-switch wrapper scripts are used during build.
CONFIGURE_ENV+=	DEFAULT_AUTOCONF=${_AUTORECONF}
MAKE_ENV+=	DEFAULT_AUTOCONF=${_AUTORECONF}

.  if ! ${autoreconf_ARGS:Mbuild}
_USES_configure+=	470:do-autoreconf

do-autoreconf:
.    for f in AUTHORS ChangeLog INSTALL NEWS README
	# Don't modify time stamps if the files already exist
	@test -e ${AUTORECONF_WRKSRC}/${f} || ${TOUCH} ${AUTORECONF_WRKSRC}/${f}
.    endfor
	@(cd ${AUTORECONF_WRKSRC} && if ! ${AUTORECONF} -f -i; then \
		${ECHO_MSG} '===>  Mk/Uses/autoreconf.mk: Error running ${AUTORECONF}'; \
		${FALSE}; fi)
.  endif

.endif

# _INCLUDE_USES_AUTORECONF_MK
