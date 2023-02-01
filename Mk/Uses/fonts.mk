# handle fonts
# Feature:	fonts
# Usage:	USES=fonts
# Valid ARGS:	fc, fontsdir, fcfontsdir (implicit)

#  fc		Add @fc ${FONTSDIR} to primary|single subpackage manifest
#  fontsdir	Add @fontsdir ${FONTSDIR} to primary|single subpackage manifest
#  fcfontsdir	Add @fcfontsdir ${FONTSDIR} to primary|single subpackage manifest

# Ports should use USES=fonts with an argument only when necessary.
# By default, @fcfontsdir ${FONTSDIR} is added and it updates font
# information cache file of fontconfig library, and XLFD entries
# in fonts.dir and fonts.scale file, which are directly used by
# X server and xfs font server.
#
# Xorg supports TrueType and OpenType via either of the two font
# subsystems.  @fcfontsdir is designed to update configuration files for
# both of them to register a font file.  Specifically, fc-cache and
# mkfontdir utilities are used, respectively.
#
# Ports to install fonts with which mkfontdir or fc-cache do not work well
# should use :fc and/or :fontsdir argument.  fc-cache and mkfontdir
# get information such as fontname, encoding, etc. from a font file.
# However, mkfontdir does not understand information in some scalable
# fonts.  Typical examples are TrueType Collection format and
# CJK (Chinese, Japanese, and Korean) TrueType font.  The former is
# a format which contains multiple fonts in a single file.
# While Xorg supports it, mkfontdir does not generate correct
# fonts.dir entries from a TTC font.  CJK fonts often require
# modifiers in a XFLD entry to enable special feature which mkfontdir
# does not support, either.
#
# Note that ports which do not want mkfontdir need to use
# a separate FONTSDIR, not shared ones such as misc or TTF.
# This is because other ports using @fcfontsdir or @fontsdir
# update fonts.dir in these font directories upon installation
# and deinstallation.  mkfontdir will overwrite manually-added entries.

.if !defined(_INCLUDE_USES_FONTS_MK)
_INCLUDE_USES_FONTS_MK=	yes

.  if empty(fonts_ARGS)
fonts_ARGS=	fcfontsdir
.  endif

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# if argument = fc:
# BUILD_DEPENDS+=	fontconfig:dev:standard
# BUILDRUN_DEPENDS+=	fontconfig:primary:standard
# -----------------------------------------------
# if argument = fcfontsdir:
# BUILD_DEPENDS+=	fontconfig:dev:standard
# BUILDRUN_DEPENDS+=	fontconfig:primary:standard
# RUN_DEPENDS+=		xorg-mkfontscale:single:standard
# -----------------------------------------------
# if argument = fontsdir:
# RUN_DEPENDS+=		xorg-mkfontscale:single:standard
# -----------------------------------------------
# Unrecognized arguments are removed from buildsheet
# If multiple recognized arguments are provided, all after
# the first one removed.
# -----------------------------------------------

FONTNAME?=	you-must-define-FONTNAME
FONTROOTDIR?=	${PREFIX}/share/fonts
FONTSDIR?=	${FONTROOTDIR}/${FONTNAME}
SUB_LIST+=	FONTSDIR="${FONTSDIR}"
PLIST_SUB+=	FONTSDIR="${FONTSDIR:S,^${PREFIX}/,,}"

.  if ${SUBPACKAGES:Mprimary}
SPKGMANIFEST=	${WRKDIR}/.manifest.primary.mktmp
.  elif ${SUBPACKAGES:Msingle}
SPKGMANIFEST=	${WRKDIR}/.manifest.single.mktmp
.  else
SPKGMANIFEST=	${WRKDIR}/font.mk-error
.  endif

_USES_stage+=	933:add-plist-fonts

.  if !target(add-plist-fonts)
add-plist-fonts:
	@echo "@${fonts_ARGS} ${FONTSDIR}" >> ${SPKGMANIFEST}
.  endif

.endif	# _INCLUDE_USES_FONTS_MK
