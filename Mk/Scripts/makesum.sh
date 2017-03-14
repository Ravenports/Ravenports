#!/bin/sh

set -e

. "${dp_SCRIPTSDIR}/functions.sh"

validate_env dp_CHECKSUM_ALGORITHMS dp_CKSUMFILES dp_DISTDIR dp_DISTINFO_FILE \
	dp_ECHO_MSG

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_MAKESUM}" ] && set -x

set -u

DISTINFO_NEW=$(mktemp -t makesum-new)

trap 'rm -f ${DISTINFO_NEW}' EXIT INT TERM

check_checksum_algorithms

cd "${dp_DISTDIR}"

for file in ${dp_CKSUMFILES}; do
	for alg in ${dp_CHECKSUM_ALGORITHMS}; do
		eval "alg_executable=\$dp_$alg"

		if [ "$alg_executable" != "NO" ]; then
			hash=$($alg_executable -q "$file")
			size=$(stat -f %z "$file")
			echo | awk -v hash="${hash}" -v size="${size}" -v fn="${file}" \
			'{printf "%s %12s %s\n", hash, size, fn}' >> "${DISTINFO_NEW}"
		fi
	done
done
cat ${DISTINFO_NEW} > ${dp_DISTINFO_FILE}
