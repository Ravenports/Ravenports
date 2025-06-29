#!/bin/sh

message_file() {
	FILENAME="$1"
	PHP_MODNAME="$2"
	TYPEXT="$3"
	INI_FILE="$4"

	cat <<EOF >> "${FILENAME}"
php_in: {
    type: "install"
    message: <<EOS
The following contents of the installed ${INI_FILE}
configuration file automatically loads the ${PHP_MODNAME} extension:
    ${TYPEXT}
EOS
}
php_out:  {
    type: "remove"
    message: "The ${PHP_MODNAME} extension has been removed from ${INI_FILE}"
}
EOF
}

scripts_file() {
	FILENAME="$1"
	PHP_MODNAME="$2"
	PHPXX="$3"

	cat <<EOF >> "${FILENAME}"
post-install-lua: [{
    args: ""
    code: <<EOS
cfg = pkg.prefixed_path("include/${PHPXX}/ext/php_config.h")
file = io.open(cfg,"a")
file:write('#include "ext/${PHP_MODNAME}/config.h"\n')
file:close()
EOS
}]
pre-deinstall-lua: [{
   args: ""
   code: <<EOS
cfg = pkg.prefixed_path("include/${PHPXX}/ext/php_config.h")
cfg_last = cfg .. ".last"
sed_prog = "/usr/bin/sed"
st = pkg.stat(sed_prog)
if not st then
   sed_prog = "/bin/sed"
   st = pkg.stat(sed_prog)
   if not st then
      pkg.print_msg("No sed program found - ${PHP_MODNAME} not removed from configuration")
      return false
   end
end
pkg.exec({sed_prog, "-i.last", "-e", "/ext.${PHP_MODNAME}.config.h/d", cfg})
st = pkg.stat(cfg_last)
if st then
   os.remove(cfg_last)
end
st = pkg.stat(cfg)
if st then
   if st.size == 0 then
      os.remove(cfg)
   end
end
EOS
}]
EOF
}

MYFUNC="$1"
shift

case "$MYFUNC" in
    message) message_file $@ ;;
    script) scripts_file $@ ;;
    *) ;;
esac
