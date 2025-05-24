#!/bin/sh
# This file for common functions used for ravenport scripts.
# shellcheck disable=SC2016,SC2154

validate_env() {
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
	alg=$1
	file=$2
	# distinfo: sha256-hash size filename
	prog='{ if (file == $3) { \
	if (alg == "SIZE") print $2; else print $1; \
	exit }}'

	if [ -n "${dp_DISABLE_CHECKSUM}" ] || [ ! -f "${dp_DISTINFO_FILE}" ]; then
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

dynamic_timeout() {
	# Set timeout based on 8mbps minimum download speed

	filesize=$1
	result=4800  # 80 minutes

	if [ "$filesize" -lt 300000000 ]; then
		result=300
	elif [ "$filesize" -lt 600000000 ]; then
		result=600
	elif [ "$filesize" -lt 900000000 ]; then
		result=900
	elif [ "$filesize" -lt 1200000000 ]; then
		result=1200
	elif [ "$filesize" -lt 1500000000 ]; then
		result=1500
	elif [ "$filesize" -lt 1800000000 ]; then
		result=1800
	elif [ "$filesize" -lt 2100000000 ]; then
		result=2100
	elif [ "$filesize" -lt 2400000000 ]; then
		result=2400
	elif [ "$filesize" -lt 2700000000 ]; then
		result=2700
	elif [ "$filesize" -lt 3000000000 ]; then
		result=3000
	elif [ "$filesize" -lt 3300000000 ]; then
		result=3300
	elif [ "$filesize" -lt 3600000000 ]; then
		result=3600
	elif [ "$filesize" -lt 3900000000 ]; then
		result=3900
	elif [ "$filesize" -lt 4200000000 ]; then
		result=4200
	elif [ "$filesize" -lt 4500000000 ]; then
		result=4500
	fi
	echo "$result"
}
