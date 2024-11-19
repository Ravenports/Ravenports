#!/bin/sh

schema_file() {
	FILENAME="$1"
	OPTIONS="$2"
	DIRECTORY="$3"
	WRKDIR="$4"
	NAME="$5"

	cat <<EOF >> "${FILENAME}.add"
{
    args: ""
    code: <<EOS
gconf_dir = pkg.prefixed_path("${DIRECTORY}")
rulename  = pkg.prefixed_path("etc/gconf/schemas/${NAME}")
src = "GCONF_CONFIG_SOURCE=xml:${OPTIONS}:" .. gconf_dir
home = "HOME=${WRKDIR}"
prog = "gconftool-2"
rule = "--makefile-install-rule"
cmd  = prog .. " " .. rule .. " " .. rulename .. " > /dev/null 2>&1"
pkg.print_msg("Installing schema rule " .. rulename)
pkg.exec({"/usr/bin/env", src, home, "/bin/sh", "-c", cmd})
EOS
}
EOF
	cat <<EOF >> "${FILENAME}.rem"
{
   args: ""
   code: <<EOS
gconf_dir = pkg.prefixed_path("${DIRECTORY}")
rulename  = pkg.prefixed_path("etc/gconf/schemas/${NAME}")
src = "GCONF_CONFIG_SOURCE=xml:${OPTIONS}:" .. gconf_dir
home = "HOME=${WRKDIR}"
prog = "gconftool-2"
rule = "--makefile-uninstall-rule"
cmd  = prog .. " " .. rule .. " " .. rulename .. " > /dev/null 2>&1"
pkg.print_msg("Removing schema rule " .. rulename)
pkg.exec({"/usr/bin/env", src, home, "/bin/sh", "-c", cmd})
EOS
}
EOF
}

make_one_file() {
	FILENAME="$1"

	echo "post-install-lua: [" > "${FILENAME}"
	cat "${FILENAME}.add" >> "${FILENAME}"
	echo "]" >> "${FILENAME}"
	echo "pre-deinstall-lua: [" >> "${FILENAME}"
	cat "${FILENAME}.rem" >> "${FILENAME}"
	echo "]" >> "${FILENAME}"
}


MYFUNC="$1"
shift

case "$MYFUNC" in
    schema) schema_file $@ ;;
    finalize) make_one_file $@ ;;
    *) ;;
esac
