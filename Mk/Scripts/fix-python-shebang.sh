#!/bin/sh
#
# Used by Uses/python.mk
# argument 1 is equivalent to ${STAGEDIR}
# argument 2 is equivalent to ${PREFIX}
# argument 3 is the python command

PCMD="${3}"
PENV="/usr/bin/env python"
PY3C="/usr/bin/python3"
SARG="1s|^\#![[:space:]]*${PENV}\([[:space:]]\)|\#!${PCMD}\1|; 1s|^\#![[:space:]]*${PENV}\$|\#!${PCMD}|"
SAR2="1s|^\#![[:space:]]*${PY3C}\([[:space:]]\)|\#!${PCMD}\1|; 1s|^\#![[:space:]]*${PY3C}\$|\#!${PCMD}|"

check_file() {
	f="$1"
	top_line=$(sed -n -e '1s/^#![[:space:]]*\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\).*/\1 \2/p;2q' "${f}")

	interp=${top_line% *}
	interparg=${top_line#* }

	case "${interp}" in
	/usr/bin/env)
		if [ "$interparg" = "python" ]; then
			echo "==> Adjusting /usr/bin/env shebang: ${f}"
			sed -i'' -e "${SARG}" "${f}"
		fi
		;;
	/usr/bin/python3)
		echo "==> Adjusting /usr/bin/python3 shebang: ${f}"
		sed -i'' -e "${SAR2}" "${f}"
		;;
	esac
}

find "${1}${2}" -type f -perm /111 2>/dev/null | while read -r ff; do
    check_file "$ff"
done
