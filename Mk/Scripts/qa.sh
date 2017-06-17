#!/bin/sh

if [ -z "${STAGEDIR}" -o -z "${PREFIX}" -o -z "${LOCALBASE}" ]; then
	echo "STAGEDIR, PREFIX, LOCALBASE required in environment." >&2
	exit 1
fi

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_QA}" ] && set -x

notice() {
	echo "Notice: $@" >&2
}

warn() {
	echo "Warning: $@" >&2
}

err() {
	echo "Error: $@" >&2
}

list_stagedir_elfs() {
	cd ${STAGEDIR} && find . -type f \( -perm /111 -o -name '*.so*' \) "$@" | sort
}

shebangonefile() {
	local f interp interparg badinterp rc

	f="$@"
	rc=0

	# whitelist some files
	case "${f}" in
	*.pm|*.pod|*.txt)
		return 0
		;;
	esac

	interp=$(sed -n -e '1s/^#![[:space:]]*\([^[:space:]]*\).*/\1/p;2q' "${f}")
	badinterp=""
	case "${interp}" in
	"") ;;
	${LOCALBASE}/bin/python|${PREFIX}/bin/python)
		badinterp="${interp}"
		;;
	${LOCALBASE}/bin/perl5.* | ${PREFIX}/bin/perl5.*)
		# Non-default perl ports are allowed to have these shebangs.
		if [ "${NAMEBASE}" != "perl-5.24" ]; then
			err "'${interp}' is an invalid shebang for '${f#${STAGEDIR}${PREFIX}/}' you must use ${LOCALBASE}/bin/perl."
			err "Either pass \${PERL} to the build or use USES=shebangfix"
			rc=1
		fi
		;;
	${LOCALBASE}/*) ;;
	${PREFIX}/*) ;;
	/bin/sh) ;;
	/bin/csh) ;;	# not in ravensys-root
	/bin/tcsh) ;;	# not in ravensys-root
	/bin/dash)	# Only valid for linux
		if [ "${OPSYS}" != "Linux" ]; then
			badinterp="${interp}"
		fi
		;;
	/usr/bin/awk) ;;
	/usr/bin/env)
		interparg=$(sed -n -e '1s/^#![[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\).*/\1/p;2q' "${f}")
		case "${interparg}" in
		python)
			badinterp="${interp} ${interparg}"
			;;
		esac
		;;
	/usr/bin/sed) ;;
	*)
		badinterp="${interp}"
		;;
	esac

	if [ -n "${badinterp}" ]; then
		err "'${badinterp}' is an invalid shebang you need USES=shebangfix for '${f#${STAGEDIR}${PREFIX}/}'"
		rc=1
	fi

	return ${rc}
}

shebang() {
	local f l link rc

	rc=0

	while read f; do
		# No results presents a blank line from heredoc.
		[ -z "${f}" ] && continue
		shebangonefile "${f}" || rc=1
	# Use heredoc to avoid losing rc from find|while subshell
	done <<-EOF
	$(find ${STAGEDIR}${PREFIX} \
	    -type f -perm /111 2>/dev/null)
	EOF

	# Split stat(1) result into 2 lines and read each line separately to
	# retain spaces in filenames.
	while read l; do
		# No results presents a blank line
		[ -z "${l}" ] && continue
		read link

		case "${link}" in
		/*) f="${STAGEDIR}${link}" ;;
		*) f="${l%/*}/${link}" ;;
		esac
		if [ -f "${f}" ]; then
			shebangonefile "${f}" || rc=1
		fi
	# Use heredoc to avoid losing rc from find|while subshell
	done <<-EOF
	$(find ${STAGEDIR} -type l -print0 | xargs -0 -i sh -c 'echo "{}" && readlink "{}"')
	EOF

	return ${rc}
}

symlinks() {
	local rc

	rc=0

	# Split stat(1) result into 2 lines and read each line separately to
	# retain spaces in filenames.
	while read l; do
		# No results presents a blank line from heredoc.
		[ -z "${l}" ] && continue
		read link
		case "${link}" in
			${STAGEDIR}*)
				err "Bad symlink '${l#${STAGEDIR}${PREFIX}/}' pointing inside the stage directory"
				rc=1
				;;
			/*)
				# Only warn for symlinks within the package.
				if [ -e "${STAGEDIR}${link}" ]; then
					warn "Bad symlink '${l#${STAGEDIR}}' pointing to an absolute pathname '${link}'"
				fi
				# Also warn if the symlink exists nowhere.
				if [ ! -e "${STAGEDIR}${link}" -a ! -e "${link}" ]; then
					warn "Symlink '${l#${STAGEDIR}}' pointing to '${link}' which does not exist in the stage directory or in localbase"
				fi
				;;
		esac
	# Use heredoc to avoid losing rc from find|while subshell.
	done <<-EOF
	$(find ${STAGEDIR} -type l -print0 | xargs -0 -i sh -c 'echo "{}" && readlink "{}"')
	EOF

	return ${rc}
}

paths() {
	local rc

	rc=0

	while read f; do
		# No results presents a blank line from heredoc.
		[ -z "${f}" ] && continue
		# Ignore false-positive/harmless files
		case "${f}" in
			*/lib/ruby/gems/*) continue ;;
			*/share/texmf-var/web2c/*/*.fmt) continue ;;
			*/share/texmf-var/web2c/*/*.log) continue ;;
		esac
		err "'${f#${STAGEDIR}${PREFIX}/}' is referring to ${STAGEDIR}"
		rc=1
	# Use heredoc to avoid losing rc from find|while subshell
	done <<-EOF
	$(find ${TMPPLIST} ${STAGEDIR} -type f -exec grep -l "${STAGEDIR}" {} +)
	EOF

	return ${rc}
}

desktopfileutils() {
	if [ -z "${USESDESKTOPFILEUTILS}" ]; then
		grep -q MimeType= ${STAGEDIR}${PREFIX}/share/applications/*.desktop 2>/dev/null &&
		warn "you need USES=desktop-file-utils"
	else
		grep -q MimeType= ${STAGEDIR}${PREFIX}/share/applications/*.desktop 2>/dev/null ||
		warn "you may not need USES=desktop-file-utils"
	fi
	return 0
}

sharedmimeinfo() {
	local f found

	found=0
	for f in ${STAGEDIR}${PREFIX}/share/mime/packages/*.xml; do
		[ "${f}" = "${STAGEDIR}${PREFIX}/share/mime/packages/*.xml" ] && break #no matches
		[ "${f}" = "${STAGEDIR}${PREFIX}/share/mime/packages/freedesktop.org.xml" ] && continue
		found=1
		break
	done
	if [ -z "${USESSHAREDMIMEINFO}" -a ${found} -eq 1 ]; then
		warn "you need USES=shared-mime-info"
	elif [ -n "${USESSHAREDMIMEINFO}" -a ${found} -eq 0 ]; then
		warn "you may not need USES=shared-mime-info"
	fi
	return 0
}

suidfiles() {
	local filelist

	filelist=`find ${STAGEDIR} -type f \
		\( -perm -u+x -or -perm -g+x -or -perm -o+x \) \
		\( -perm -u+s -or -perm -g+s \)`
	if [ -n "${filelist}" ]; then
		warn "setuid files in the stage directory (are these necessary?):"
		ls -liTd ${filelist}
	fi
	return 0
}

libtool() {
	if [ -z "${USESLIBTOOL}" ]; then
		find ${STAGEDIR} -name '*.la' | while read f; do
			grep -q 'libtool library' "${f}" &&
				err ".la libraries found, port needs USES=libtool" &&
				return 1 || true
		done
		# The return above continues here.
	fi
}

prefixvar() {
	if [ -d ${STAGEDIR}${PREFIX}/var ]; then
		warn "port uses ${PREFIX}/var instead of /var"
	fi
}

terminfo() {
	local f found

	for f in ${STAGEDIR}${PREFIX}/share/misc/*.terminfo; do
		[ "${f}" = "${STAGEDIR}${PREFIX}/share/misc/*.terminfo" ] && break #no matches
		found=1
		break
	done
	for f in ${STAGEDIR}${PREFIX}/share/misc/terminfo.db*; do
		[ "${f}" = "${STAGEDIR}${PREFIX}/share/misc/terminfo.db*" ] && break #no matches
		found=1
		break
	done
	if [ -z "${USESTERMINFO}" -a -n "${found}" ]; then
		warn "you need USES=terminfo"
	elif [ -n "${USESTERMINFO}" -a -z "${found}" ]; then
		warn "you may not need USES=terminfo"
	fi
	return 0
}

listcontains() {
	local str lst elt
	str=$1
	lst=$2

	for elt in ${lst} ; do
		if [ ${elt} = ${str} ]; then
			return 0
		fi
	done
	return 1
}

proxydeps_suggest_uses() {
	local pkg=$1
	local lib_file=$2

	# miscellaneous USE clauses
	if [ ${pkg} = 'gettext:standard' ]; then
		warn "you need USES+=gettext-runtime"
	elif [ ${pkg} = 'sqlite:standard' ]; then
		warn "you need USES+=sqlite"
	# Gnome -> same as port
	# grep LIB_DEPENDS= Mk/Uses/gnome.mk |sed -e 's|\(.*\)_LIB_DEPENDS.*:\(.*\)\/\(.*\)|[ "\1" = "\3" ] \&\& echo "\\${pkg} = \\\"\2/\3\\\" -o \\\\"|'|sort|sh
	elif [ ${pkg} = "libxml2:standard" -o \
		${pkg} = "libxslt:standard" ]; then
		warn "you need XORG_COMPONENTS+=${pkg#*:}"
	# Xorg-libraries: this should be by XORG_MODULES @ bsd.xorg.mk
	elif echo ${pkg} | grep -E '/lib(X11|Xau|Xdmcp|Xext|SM|ICE|Xfixes|Xft|Xdamage|Xcomposite|Xcursor|Xinerama|Xmu|Xmuu|Xpm|Xt|Xtst|Xi|Xrandr|Xrender|Xres|XScrnSaver|Xv|Xxf86vm|Xxf86dga|Xxf86misc|xcb)$' > /dev/null; then
		warn "you need XORG_COMPONENTS+=$(echo ${pkg} | sed -E 's|.*/lib||' | tr '[:upper:]' '[:lower:]')"
	# postgresql
	elif expr ${pkg} : "postgresql.*:standard" > /dev/null; then
		warn "you need USES+=pgsql"
	# bdb
	elif expr ${pkg} : "db[56]:standard" > /dev/null; then
		warn "you need USES+=bdb"
	# ncurses
	elif [ ${pkg} = "ncurses:standard" ]; then
		warn "you need USES+=ncurses"
	# readline
	elif [ ${pkg} = "readline:standard" ]; then
		warn "you need USES+=readline"
	# ssl
	elif [ ${pkg} = "openssl:standard" -o \
		${pkg} = "openssl-devel:standard" -o \
		${pkg} = "libressl:standard" -o \
		${pkg} = "libressl-devel:standard" ]; then
		warn "you need USES=ssl"
	# lua
	elif expr ${pkg} : "lua5[2345]:standard" > /dev/null; then
		warn "you need USES+=lua"
	# Tcl
	elif expr ${pkg} = "tcl8[5678]:standard" > /dev/null; then
		warn "you need USES+=tcl"
	# MySQL
	elif expr ${lib_file} : "${LOCALBASE}/lib/mysql/[^/]*$" > /dev/null; then
		warn "you need USES+=mysql"
	# default
	elif expr ${lib_file} : "${LOCALBASE}/lib/[^/]*$" > /dev/null; then
		warn "you need BUILDRUN_DEPENDS+=${pkg}"
	fi
}

proxydeps_suggest_uses_archive() {
	local pkg=$1
	local lib_file=$2

	# miscellaneous USE clauses
	# Gnome -> same as port
	# grep LIB_DEPENDS= Mk/Uses/gnome.mk |sed -e 's|\(.*\)_LIB_DEPENDS.*:\(.*\)\/\(.*\)|[ "\1" = "\3" ] \&\& echo "\\${pkg} = \\\"\2/\3\\\" -o \\\\"|'|sort|sh
	if [ ${pkg} = "accessibility/atk" -o \
		${pkg} = "accessibility/atkmm" -o \
		${pkg} = "graphics/cairo" -o \
		${pkg} = "graphics/cairomm" -o \
		${pkg} = "devel/dconf" -o \
		${pkg} = "audio/esound" -o \
		${pkg} = "devel/gconf2" -o \
		${pkg} = "devel/gconfmm26" -o \
		${pkg} = "devel/glib12" -o \
		${pkg} = "devel/glib20" -o \
		${pkg} = "devel/glibmm" -o \
		${pkg} = "audio/gsound" -o \
		${pkg} = "x11-toolkits/gtk12" -o \
		${pkg} = "x11-toolkits/gtk20" -o \
		${pkg} = "x11-toolkits/gtk30" -o \
		${pkg} = "www/gtkhtml3" -o \
		${pkg} = "www/gtkhtml4" -o \
		${pkg} = "x11-toolkits/gtkmm20" -o \
		${pkg} = "x11-toolkits/gtkmm24" -o \
		${pkg} = "x11-toolkits/gtkmm30" -o \
		${pkg} = "x11-toolkits/gtksourceview" -o \
		${pkg} = "x11-toolkits/gtksourceview2" -o \
		${pkg} = "x11-toolkits/gtksourceview3" -o \
		${pkg} = "x11-toolkits/gtksourceviewmm3" -o \
		${pkg} = "devel/libbonobo" -o \
		${pkg} = "x11-toolkits/libbonoboui" -o \
		${pkg} = "databases/libgda5" -o \
		${pkg} = "databases/libgda5-ui" -o \
		${pkg} = "databases/libgdamm5" -o \
		${pkg} = "devel/libglade2" -o \
		${pkg} = "x11/libgnome" -o \
		${pkg} = "graphics/libgnomecanvas" -o \
		${pkg} = "x11/libgnomekbd" -o \
		${pkg} = "print/libgnomeprint" -o \
		${pkg} = "x11-toolkits/libgnomeprintui" -o \
		${pkg} = "x11-toolkits/libgnomeui" -o \
		${pkg} = "devel/libgsf" -o \
		${pkg} = "www/libgtkhtml" -o \
		${pkg} = "x11-toolkits/libgtksourceviewmm" -o \
		${pkg} = "graphics/librsvg2" -o \
		${pkg} = "devel/libsigc++12" -o \
		${pkg} = "devel/libsigc++20" -o \
		${pkg} = "x11-toolkits/libwnck" -o \
		${pkg} = "x11-toolkits/libwnck3" -o \
		${pkg} = "textproc/libxml++26" -o \
		${pkg} = "x11-wm/metacity" -o \
		${pkg} = "x11-toolkits/pango" -o \
		${pkg} = "x11-toolkits/pangomm" -o \
		${pkg} = "x11-toolkits/pangox-compat" -o \
		${pkg} = "x11-toolkits/vte" -o \
		${pkg} = "x11-toolkits/vte3" ]; then
		warn "you need USE_GNOME+=${pkg#*/}"
	# Gnome different as port
	# grep LIB_DEPENDS= Mk/Uses/gnome.mk |sed -e 's|\(.*\)_LIB_DEPENDS.*:\(.*\)\/\(.*\)|[ "\1" = "\3" ] \|\| echo "elif [ \\${pkg} = \\\"\2/\3\\\" ]; then; warn \\\"you need USE_GNOME+=\1\\\""|'|sort|sh
	elif [ ${pkg} = "databases/evolution-data-server" ]; then warn "you need USE_GNOME+=evolutiondataserver3"
	elif [ ${pkg} = "graphics/gdk-pixbuf" ]; then warn "you need USE_GNOME+=gdkpixbuf"
	elif [ ${pkg} = "graphics/gdk-pixbuf2" ]; then warn "you need USE_GNOME+=gdkpixbuf2"
	elif [ ${pkg} = "x11/gnome-desktop" ]; then warn "you need USE_GNOME+=gnomedesktop3"
	elif [ ${pkg} = "devel/gnome-vfs" ]; then warn "you need USE_GNOME+=gnomevfs2"
	elif [ ${pkg} = "devel/gobject-introspection" ]; then warn "you need USE_GNOME+=introspection"
	elif [ ${pkg} = "graphics/libart_lgpl" ]; then warn "you need USE_GNOME+=libartlgpl2"
	elif [ ${pkg} = "devel/libIDL" ]; then warn "you need USE_GNOME+=libidl"
	elif [ ${pkg} = "x11-fm/nautilus" ]; then warn "you need USE_GNOME+=nautilus3"
	elif [ ${pkg} = "devel/ORBit2" ]; then warn "you need USE_GNOME+=orbit2"
	# mate
	# grep LIB_DEPENDS= Mk/Uses/mate.mk |sed -e 's|\(.*\)_LIB_DEPENDS.*:\(.*\)\/\(.*\)|elif [ ${pkg} = "\2/\3" ]; then warn "you need USE_MATE+=\1"|'
	elif [ ${pkg} = "x11-fm/caja" ]; then warn "you need USE_MATE+=caja"
	elif [ ${pkg} = "sysutils/mate-control-center" ]; then warn "you need USE_MATE+=controlcenter"
	elif [ ${pkg} = "x11/mate-desktop" ]; then warn "you need USE_MATE+=desktop"
	elif [ ${pkg} = "x11/libmatekbd" ]; then warn "you need USE_MATE+=libmatekbd"
	elif [ ${pkg} = "net/libmateweather" ]; then warn "you need USE_MATE+=libmateweather"
	elif [ ${pkg} = "x11-wm/marco" ]; then warn "you need USE_MATE+=marco"
	elif [ ${pkg} = "x11/mate-menus" ]; then warn "you need USE_MATE+=menus"
	elif [ ${pkg} = "x11/mate-panel" ]; then warn "you need USE_MATE+=panel"
	elif [ ${pkg} = "sysutils/mate-polkit" ]; then warn "you need USE_MATE+=polkit"
	# KDE
	# grep -B1 _LIB= Mk/Uses/kde.mk | grep _PORT=|sed -e 's/^\(.*\)_PORT=[[:space:]]*\([^[:space:]]*\).*/elif [ ${pkg} = "\2" ]; then warn "you need to use USE_KDE+=\1"/'
	elif [ ${pkg} = "sysutils/baloo" ]; then warn "you need to use USE_KDE+=baloo"
	elif [ ${pkg} = "sysutils/baloo-widgets" ]; then warn "you need to use USE_KDE+=baloo-widgets"
	elif [ ${pkg} = "x11/kactivities" ]; then warn "you need to use USE_KDE+=kactivities"
	elif [ ${pkg} = "editors/kate" ]; then warn "you need to use USE_KDE+=kate"
	elif [ ${pkg} = "x11/kdelibs4" ]; then warn "you need to use USE_KDE+=kdelibs"
	elif [ ${pkg} = "sysutils/kfilemetadata" ]; then warn "you need to use USE_KDE+=kfilemetadata"
	elif [ ${pkg} = "audio/libkcddb" ]; then warn "you need to use USE_KDE+=libkcddb"
	elif [ ${pkg} = "audio/libkcompactdisc" ]; then warn "you need to use USE_KDE+=libkcompactdisc"
	elif [ ${pkg} = "graphics/libkdcraw-kde4" ]; then warn "you need to use USE_KDE+=libkdcraw"
	elif [ ${pkg} = "misc/libkdeedu" ]; then warn "you need to use USE_KDE+=libkdeedu"
	elif [ ${pkg} = "games/libkdegames" ]; then warn "you need to use USE_KDE+=libkdegames"
	elif [ ${pkg} = "graphics/libkexiv2-kde4" ]; then warn "you need to use USE_KDE+=libkexiv2"
	elif [ ${pkg} = "graphics/libkipi-kde4" ]; then warn "you need to use USE_KDE+=libkipi"
	elif [ ${pkg} = "x11/libkonq" ]; then warn "you need to use USE_KDE+=libkonq"
	elif [ ${pkg} = "graphics/libksane" ]; then warn "you need to use USE_KDE+=libksane"
	elif [ ${pkg} = "astro/marble" ]; then warn "you need to use USE_KDE+=marble"
	elif [ ${pkg} = "sysutils/nepomuk-core" ]; then warn "you need to use USE_KDE+=nepomuk-core"
	elif [ ${pkg} = "sysutils/nepomuk-widgets" ]; then warn "you need to use USE_KDE+=nepomuk-widgets"
	elif [ ${pkg} = "graphics/okular" ]; then warn "you need to use USE_KDE+=okular"
	elif [ ${pkg} = "deskutils/kdepimlibs4" ]; then warn "you need to use USE_KDE+=pimlibs"
	elif [ ${pkg} = "devel/ruby-qtruby" ]; then warn "you need to use USE_KDE+=qtruby"
	elif [ ${pkg} = "devel/smokegen" ]; then warn "you need to use USE_KDE+=smokegen"
	elif [ ${pkg} = "devel/smokekde" ]; then warn "you need to use USE_KDE+=smokekde"
	elif [ ${pkg} = "devel/smokeqt" ]; then warn "you need to use USE_KDE+=smokeqt"
	elif [ ${pkg} = "x11/kde4-workspace" ]; then warn "you need to use USE_KDE+=workspace"
	elif [ ${pkg} = "databases/akonadi" ]; then warn "you need to use USE_KDE+=akonadi"
	elif [ ${pkg} = "x11-toolkits/attica" ]; then warn "you need to use USE_KDE+=attica"
	elif [ ${pkg} = "x11/qimageblitz" ]; then warn "you need to use USE_KDE+=qimageblitz"
	elif [ ${pkg} = "textproc/soprano" ]; then warn "you need to use USE_KDE+=soprano"
	elif [ ${pkg} = "deskutils/libstreamanalyzer" ]; then warn "you need to use USE_KDE+=strigi"
	# KDE Frameworks
	elif [ ${pkg} = "devel/kf5-extra-cmake-modules" ]; then warn "you need to use USE_KDE+=ecm"
	elif [ ${pkg} = "devel/kf5-kcmutils" ]; then warn "you need to use USE_KDE+=kcmutils"
	elif [ ${pkg} = "devel/kf5-kdeclarative" ]; then warn "you need to use USE_KDE+=kdeclarative"
	elif [ ${pkg} = "devel/kf5-kfilemetadata" ]; then warn "you need to use USE_KDE+=filemetadata5"
	elif [ ${pkg} = "devel/kf5-kio" ]; then warn "you need to use USE_KDE+=kio"
	elif [ ${pkg} = "devel/kf5-solid" ]; then warn "you need to use USE_KDE+=solid"
	elif [ ${pkg} = "devel/kf5-threadweaver" ]; then warn "you need to use USE_KDE+=threadweaver"
	elif [ ${pkg} = "devel/kio-extras-kf5" ]; then warn "you need to use USE_KDE+=kio-extras"
	elif [ ${pkg} = "graphics/kf5-kimageformats" ]; then warn "you need to use USE_KDE+=kimageformats"
	elif [ ${pkg} = "lang/kf5-kross" ]; then warn "you need to use USE_KDE+=kross"
	elif [ ${pkg} = "security/kf5-kdesu" ]; then warn "you need to use USE_KDE+=kdesu"
	elif [ ${pkg} = "sysutils/kf5-baloo" ]; then warn "you need to use USE_KDE+=baloo5"
	elif [ ${pkg} = "sysutils/kf5-bluez-qt" ]; then warn "you need to use USE_KDE+=bluez-qt"
	elif [ ${pkg} = "textproc/kf5-sonnet" ]; then warn "you need to use USE_KDE+=sonnet"
	elif [ ${pkg} = "www/kf5-kdewebkit" ]; then warn "you need to use USE_KDE+=kdewebkit"
	elif [ ${pkg} = "www/kf5-khtml" ]; then warn "you need to use USE_KDE+=khtml"
	elif [ ${pkg} = "x11-themes/kf5-breeze-icons" ]; then warn "you need to use USE_KDE+=breeze-icons"
	elif [ ${pkg} = "x11-themes/kf5-oxygen-icons5" ]; then warn "you need to use USE_KDE+=oxygen-icons5"
	elif [ ${pkg} = "x11-toolkits/kf5-attica" ]; then warn "you need to use USE_KDE+=attica5"
	elif [ ${pkg} = "x11/kf5-frameworkintegration" ]; then warn "you need to use USE_KDE+=frameworkintegration"
	elif [ ${pkg} = "x11/kf5-kded" ]; then warn "you need to use USE_KDE+=kded"
	elif [ ${pkg} = "x11/kf5-kdelibs4support" ]; then warn "you need to use USE_KDE+=kdelibs4support"
	elif [ ${pkg} = "x11/kf5-plasma-framework" ]; then warn "you need to use USE_KDE+=plasma-framework"
	elif expr ${pkg} : '.*/kf5-.*' > /dev/null; then
		warn "you need USE_KDE+=$(echo ${pkg} | sed -E 's|.*/kf5-k||')"
	# sdl-related
	elif [ ${pkg} = 'devel/sdl12' ]; then
		warn "you need USE_SDL+=sdl"
	elif echo ${pkg} | grep -E '/sdl_(console|gfx|image|mixer|mm|net|pango|sound|ttf)$' > /dev/null; then
		warn "you need USE_SDL+=$(echo ${pkg} | sed -E 's|.*/sdl_||')"
	elif [ ${pkg} = 'devel/sdl20' ]; then
		warn "you need USE_SDL+=sdl2"
	elif echo ${pkg} | grep -E '/sdl2_(gfx|image|mixer|net|ttf)$' > /dev/null; then
		warn "you need USE_SDL+=$(echo ${pkg} | sed -E 's|.*/sdl2_||')2"
	# gl-related
	elif [ ${pkg} = 'graphics/libGL' ]; then
		warn "you need USE_GL+=gl"
	elif [ ${pkg} = 'graphics/gbm' ]; then
		warn "you need USE_GL+=gbm"
	elif [ ${pkg} = 'graphics/libglesv2' ]; then
		warn "you need USE_GL+=glesv2"
	elif [ ${pkg} = 'graphics/libEGL' ]; then
		warn "you need USE_GL+=egl"
	elif [ ${pkg} = 'graphics/glew' ]; then
		warn "you need USE_GL+=glew"
	elif [ ${pkg} = 'graphics/libGLU' ]; then
		warn "you need USE_GL+=glu"
	elif [ ${pkg} = 'graphics/libGLw' ]; then
		warn "you need USE_GL+=glw"
	elif [ ${pkg} = 'graphics/freeglut' ]; then
		warn "you need USE_GL+=glut"
	# last xorg
	elif [ ${pkg} = 'x11/pixman' ]; then
		warn "you need USE_XORG+=pixman"
	# Qt4
	elif expr ${pkg} : '.*/qt4-.*' > /dev/null; then
		warn "you need USE_QT4+=$(echo ${pkg} | sed -E 's|.*/qt4-||')"
	elif expr ${pkg} : '.*/.*-qt4' > /dev/null; then
		warn "you need USE_QT4+=$(echo ${pkg} | sed -E 's|.*/(.*)-qt4|\1|')"
	# Qt5
	elif expr ${pkg} : '.*/qt5-.*' > /dev/null; then
		warn "you need USE_QT5+=$(echo ${pkg} | sed -E 's|.*/qt5-||')"
	elif expr ${pkg} : '.*/.*-qt5' > /dev/null; then
		warn "you need USE_QT5+=$(echo ${pkg} | sed -E 's|.*/(.*)-qt5|\1|')"
	# execinfo
	elif [ ${pkg} = "devel/libexecinfo" ]; then
		warn "you need USES+=execinfo"
	# fam/gamin
	elif [ ${pkg} = "devel/fam" -o ${pkg} = "devel/gamin" ]; then
		warn "you need USES+=fam"
	# firebird
	elif [ ${pkg} = "databases/firebird25-client" ]; then
		warn "you need USES+=firebird"
	# fuse
	elif [ ${pkg} = "sysutils/fusefs-libs" ]; then
		warn "you need USES+=fuse"
	# gnustep
	elif [ ${pkg} = "lang/gnustep-base" ]; then
		warn "you need USES+=gnustep and USE_GNUSTEP+=base"
	elif [ ${pkg} = "x11-toolkits/gnustep-gui" ]; then
		warn "you need USES+=gnustep and USE_GNUSTEP+=gui"
	# iconv
	elif [ ${pkg} = "converters/libiconv" ]; then
		warn "you need USES+=iconv"
	# jpeg
	elif [ ${pkg} = "graphics/jpeg" -o ${pkg} = "graphics/jpeg-turbo" ]; then
		warn "you need USES+=jpeg"
	# libarchive
	elif [ ${pkg} = "archivers/libarchive" ]; then
		warn "you need USES+=libarchive"
	elif [ ${pkg} = "devel/libedit" ]; then
		warn "you need USES+=libedit"
	# motif
	elif [ ${pkg} = "x11-toolkits/lesstif" -o ${pkg} = "x11-toolkits/open-motif" ]; then
		warn "you need USES+=motif"
	# objc
	elif [ ${pkg} = "lang/libobjc2" ]; then
		warn "you need USES+=objc"
	# openal
	elif [ ${pkg} = "audio/openal" -o ${pkg} = "audio/openal-soft" -o ${pkg} = "audio/freealut" ]; then
		warn "you need USES+=openal"
	# pure
	elif [ ${pkg} = "lang/pure" ]; then
		warn "you need USES+=pure"
	# Xfce
	# grep LIB_DEPENDS= Mk/Uses/xfce.mk |sed -e 's|\(.*\)_LIB_DEPENDS.*:\(.*\)\/\(.*\)|elif [ ${pkg} = "\2/\3" ]; then warn "you need USE_XFCE+=\1"|'
	elif [ ${pkg} = "sysutils/garcon" ]; then warn "you need USE_XFCE+=garcon"
	elif [ ${pkg} = "x11/libexo" ]; then warn "you need USE_XFCE+=libexo"
	elif [ ${pkg} = "x11-toolkits/libxfce4gui" ]; then warn "you need USE_XFCE+=libgui"
	elif [ ${pkg} = "x11/libxfce4menu" ]; then warn "you need USE_XFCE+=libmenu"
	elif [ ${pkg} = "x11/libxfce4util" ]; then warn "you need USE_XFCE+=libutil"
	elif [ ${pkg} = "x11-wm/xfce4-panel" ]; then warn "you need USE_XFCE+=panel"
	elif [ ${pkg} = "x11-fm/thunar" ]; then warn "you need USE_XFCE+=thunar"
	elif [ ${pkg} = "x11/xfce4-conf" ]; then warn "you need USE_XFCE+=xfconf"
	# default
	elif expr ${lib_file} : "${LOCALBASE}/lib/[^/]*$" > /dev/null; then
		lib_file=${lib_file#${LOCALBASE}/lib/}
		lib_file=${lib_file%.so*}.so
		warn "you need LIB_DEPENDS+=${pkg}"
	fi
}

proxydeps() {
	local file dep_file dep_file_pkg already rc

	rc=0

	# Check all dynamicaly linked ELF files
	# Some .so are not executable, but we want to check them too.
	while read file; do
		# No results presents a blank line from heredoc.
		[ -z "${file}" ] && continue
		while read dep_file; do
			# No results presents a blank line from heredoc.
			[ -z "${dep_file}" ] && continue
			# Skip files we already checked.
			if listcontains ${dep_file} "${already}"; then
				continue
			fi
			if $(pkg-static which -q ${dep_file} > /dev/null 2>&1); then
				dep_file_pkg=$(pkg-static which -qo ${dep_file})

				# Check that the .so we need has a SONAME
				if [ "${dep_file_pkg}" != "${PKGORIGIN}" ]; then
					if ! readelf -d "${dep_file}" | grep -q SONAME; then
						err "${file} is linked to ${dep_file} which does not have a SONAME.  ${dep_file_pkg} needs to be fixed."
					fi
				fi

				# If we don't already depend on it, and we don't provide it
				if ! listcontains ${dep_file_pkg} "${LIB_RUN_DEPENDS} ${PKGORIGIN}"; then
					err "${file} is linked to ${dep_file} from ${dep_file_pkg} but it is not declared as a dependency"
					proxydeps_suggest_uses ${dep_file_pkg} ${dep_file}
					rc=1
				fi
			else
				err "${file} is linked to ${dep_file} that does not belong to any package"
				rc=1
			fi
			already="${already} ${dep_file}"
		done <<-EOT
		$(ldd -a "${STAGEDIR}${file}" | \
			awk '\
			BEGIN {section=0}\
			/^\// {section++}\
			!/^\// && section<=1 && ($3 ~ "^'${PREFIX}'" || $3 ~ "^'${LOCALBASE}'") {print $3}')
		EOT
	done <<-EOT
	$(list_stagedir_elfs | \
		file -F $'\1' -f - | \
		grep -a 'ELF.*dynamically linked' | \
		cut -f 1 -d $'\1'| \
		sed -e 's/^\.//')
	EOT

	[ -z "${PROXYDEPS_FATAL}" ] && return 0

	return ${rc}
}

sonames() {
	[ ! -d ${STAGEDIR}${PREFIX}/lib -o -n "${BUNDLE_LIBS}" ] && return 0
	while read f; do
		# No results presents a blank line from heredoc.
		[ -z "${f}" ] && continue
		# Ignore symlinks
		[ -f "${f}" -a ! -L "${f}" ] || continue
		if ! readelf -d ${f} | grep -q SONAME; then
			warn "${f} doesn't have a SONAME."
			warn "pkg(8) will not register it as being provided by the port."
			warn "If another port depend on it, pkg will not be able to know where it comes from."
			case "${f}" in
				${STAGEDIR}${PREFIX}/lib/*/*)
					warn "It is in a subdirectory, it may not be used in another port."
					;;
				*)
					warn "It is directly in ${PREFIX}/lib, it is probably used by other ports."
					;;
			esac
		fi
	# Use heredoc to avoid losing rc from find|while subshell
	done <<-EOT
	$(find ${STAGEDIR}${PREFIX}/lib -name '*.so.*')
	EOT
}


checks="shebang symlinks paths desktopfileutils sharedmimeinfo"
checks="$checks suidfiles libtool prefixvar terminfo"
checks="$checks sonames" # proxydeps (requires PKGORIGIN and LIB_RUN_DEPENDS)

ret=0
cd ${STAGEDIR}
for check in ${checks}; do
	${check} || ret=1
done

exit ${ret}
