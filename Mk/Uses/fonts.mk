# handle fonts
# Feature:	fonts
# Usage:	USES=fonts
# Valid ARGS:	fc, fontsdir, fcfontsdir, none (empty means fcfontsdir)

#  fc		Add @fc ${FONTSDIR} to single subpackage manifest
#  fontsdir	Add @fontsdir ${FONTSDIR} to single subpackage manifest
#  fcfontsdir	Add @fcfontsdir ${FONTSDIR} to single subpackage manifest
#  none		No special handling of ${FONTSDIR} in single subpackage manifest

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
# BUILDRUN_DEPENDS+=	fontconfig:primary:standard
# -----------------------------------------------
# if argument = fcfontsdir:
# BUILDRUN_DEPENDS+=	fontconfig:primary:standard
#			xorg-mkfontscale:single:standard
# -----------------------------------------------
# if argument = fontdir or no argument passed:
# BUILDRUN_DEPENDS+=	xorg-mkfontscale:single:standard
# -----------------------------------------------

FONTNAME?=	you-must-define-FONTNAME
FONTROOTDIR?=	${PREFIX}/share/fonts
FONTSDIR?=	${FONTROOTDIR}/${FONTNAME}
SUB_LIST+=	FONTSDIR="${FONTSDIR}"
PLIST_SUB+=	FONTSDIR="${FONTSDIR:S,^${PREFIX}/,,}"

.if !empty(fonts_ARGS:Nnone)
_USES_stage+=	933:add-plist-fonts
.endif

.  if !target(add-plist-fonts)
add-plist-fonts:
	# fonts packages must always have one subpackage: single
	@echo "@${fonts_ARGS} ${FONTSDIR}" >> ${WRKDIR}/.manifest.single.mktmp
.  endif

.endif	# _INCLUDE_USES_FONTS_MK
