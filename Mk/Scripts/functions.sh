#!/bin/sh
# This file for common functions used for ravenport scripts.

validate_env() {
	local envfault
	for i ; do
		if ! (eval ": \${${i}?}" ) >/dev/null; then
			envfault="${envfault}${envfault:+" "}${i}"
		fi
	done
	if [ -n "${envfault}" ]; then
		echo "Environment variable ${envfault} undefined. Aborting." \
		| fmt >&2
		exit 1
	fi
}

distinfo_data() {
	local alg file prog

	alg=$1
	file=$2
	# distinfo: sha256-hash size filename
	prog='{ if (file == $3) { \
	if (alg == "SIZE") print $2; else print $1; \
	exit }}'

	if [ \( -n "${dp_DISABLE_CHECKSUM}" \) -o ! -f "${dp_DISTINFO_FILE}" ]; then
		exit
	fi
	awk -v alg="$alg" -v file="${file}" "${prog}" "${dp_DISTINFO_FILE}"
}

check_checksum_algorithms() {
	for alg in ${dp_CHECKSUM_ALGORITHMS}; do
		eval "alg_executable=\$dp_$alg"
		if [ -z "$alg_executable" ]; then
			${dp_ECHO_MSG} "Checksum algorithm $alg: Couldn't find the executable."
			${dp_ECHO_MSG} "Set $alg=/path/to/$alg in /etc/make.conf and try again."
			exit 1
		elif [ ! -x "$alg_executable" ]; then
			${dp_ECHO_MSG} "Checksum algorithm $alg: $alg_executable is not executable."
			${dp_ECHO_MSG} "Fix modes, or change $alg=$alg_executable in /etc/make.conf and try again."
			exit 1
		fi
	done
}
escape() {
	echo "$1" | sed -e 's/[&;()!#]/\\&/g'
}
unescape() {
	echo "$1" | sed -e 's/\\//g'
}
