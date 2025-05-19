#!/bin/sh
# shellcheck disable=SC1091,SC3037,SC2154

set -e

. "${dp_SCRIPTSDIR}/functions.sh"

validate_env dp_DISTDIR dp_DISTINFO_FILE dp_DISABLE_CHECKSUM dp_DISABLE_SIZE \
	dp_DIST_SUBDIR dp_ECHO_MSG dp_FETCH_CMD \
	dp_MASTER_SITE_BACKUP dp_MASTER_SITE_OVERRIDE \
	dp_MASTER_SORT_AWK dp_TARGET dp_FETCH_ENV dp_OPSYS

[ -n "${DEBUG_MK_SCRIPTS}" ] || [ -n "${DEBUG_MK_SCRIPTS_DO_FETCH}" ] && set -x

. "${dp_SCRIPTSDIR}/sites.sh"

set -u

if ! mkdir -p "${dp_DISTDIR}"/"${dp_DIST_SUBDIR}"; then
	${dp_ECHO_MSG} "=> Fatal: failed to create ${dp_DISTDIR}/${dp_DIST_SUBDIR}"
	exit 1
fi
if [ ! -w "${dp_DISTDIR}" ]; then
	${dp_ECHO_MSG} "=> Fatal: ${dp_DISTDIR} is not writable by you"
	exit 1
fi
mkdir -p "${dp_DISTDIR}"/transient

for _file in "${@}"; do
	# _file = <filename>:<sitegroup>.  Validated at spec sheet level.
	file=${_file%%:*}
	sitegroup=${_file##*:}
	full_file="${dp_DIST_SUBDIR:+${dp_DIST_SUBDIR}/}${file}"
	final_path="${dp_DISTDIR}/${dp_DIST_SUBDIR}/${file}"
	download_path="${dp_DISTDIR}/transient/${file}"
	path_hash=$(echo "$full_file" | /bin/md5)
	lockfile="${dp_DISTDIR}/transient/${path_hash}.lk"
	maxsecs=$((60 * 60 * 2)) # Put a two hour maximum on downloads
	tzero=$(date +%s)

	until [ ! -f "${lockfile}" ]
	do
		tnow=$(date +%s)
		elapsed=$((tnow - tzero))
		if [ ${elapsed} -gt ${maxsecs} ]; then
			${dp_ECHO_MSG} "=> The ${file} file was locked for 2+ hours"
			${dp_ECHO_MSG} "=> Another fetch process is downloading it"
			${dp_ECHO_MSG} "=> Consider using a faster mirror"
			exit 1
		fi
		sleep 10
	done

	touch "${lockfile}"

	if [ -f "${final_path}" ]; then
		# regular file exists.  Don't verify size or checksum
		# The makesum target will establish those properties.
		# The do-fetch target already verified them at download time
		# The extract phase will verify the checksum in case they were placed in
		# the distfiles directory by a different mechanism.
		rm -f "${lockfile}"
		continue
	fi

	if [ -e "${final_path}" ]; then
		if [ -L "${final_path}" ]; then
			${dp_ECHO_MSG} "=> ${final_path} is a broken symlink."
			${dp_ECHO_MSG} "=> Perhaps a filesystem (most likely a CD) isn't mounted?"
			${dp_ECHO_MSG} "=> Please correct this problem and try again."
		else
			${dp_ECHO_MSG} "=> ${final_path} is of an unexpected file type"
			${dp_ECHO_MSG} "=> Please investigate and correct."
		fi
		rm -f "${lockfile}"
		exit 1
	fi

	if [ -f "${dp_DISTINFO_FILE}" ] && [ -z "${dp_DISABLE_CHECKSUM}" ]; then
		_sha256sum=$(distinfo_data SHA256 "${full_file}")
		if [ -z "${_sha256sum}" ]; then
			${dp_ECHO_MSG} "=> ${full_file} is not listed in ${dp_DISTINFO_FILE}."
			${dp_ECHO_MSG} "=> The ${dp_DISTINFO_FILE} may be out of date"
			rm -f "${lockfile}"
			exit 1
		fi
	fi

	if [ -f "${dp_DISTINFO_FILE}" ] && [ -z "${dp_DISABLE_SIZE}" ]; then
		CKSIZE=$(distinfo_data SIZE "${full_file}")
		if [ -z "${CKSIZE}" ]; then
			${dp_ECHO_MSG} "=> ${full_file} is not listed in ${dp_DISTINFO_FILE}."
			${dp_ECHO_MSG} "=> The ${dp_DISTINFO_FILE} may be out of date"
			rm -f "${lockfile}"
			exit 1
		fi
	fi

	${dp_ECHO_MSG} "=> ${file} is not cached."

	__MASTER_SITES_TMP=
	# Disable nounset for this, it may come up empty, but
	# we don't want to fail with a strange error here.
	set +u
	eval __MASTER_SITES_TMP3="\${_DOWNLOAD_SITES_${sitegroup}}"
	set -u
	if [ -n "${__MASTER_SITES_TMP3}" ] ; then
		for MS3 in ${__MASTER_SITES_TMP3}; do
			__MASTER_SITES_TMP4="$(process_site "${MS3}")"
			__MASTER_SITES_TMP="${__MASTER_SITES_TMP} ${__MASTER_SITES_TMP4}"
		done
	else
		# Always - because ${dp_TARGET} is limited to (do-fetch|makesum)
		${dp_ECHO_MSG} "===> /!\\ Error /!\\"
		${dp_ECHO_MSG} "     DL_SITES_${sitegroup} site group is not defined."
		${dp_ECHO_MSG} "     Check for typos, or errors."
		rm -f "${lockfile}"
		exit 1
	fi
	__MASTER_SITES_TMP3=
	__MASTER_SITES_TMP4=
	SORTED_MASTER_SITES_CMD_TMP="echo ${dp_MASTER_SITE_OVERRIDE} $(/bin/echo -n "${__MASTER_SITES_TMP}" | awk "${dp_MASTER_SORT_AWK}") ${dp_MASTER_SITE_BACKUP}"
	sites_remaining=0
	sites="$(${SORTED_MASTER_SITES_CMD_TMP})"
	for site in ${sites}; do
		sites_remaining=$((sites_remaining + 1))
	done
	for site in ${sites}; do
		sites_remaining=$((sites_remaining - 1))

		args="-o ${download_path} ${site}${file}"
		if [ -z "${dp_DISABLE_SIZE}" ]; then
			_fetch_cmd="${dp_FETCH_CMD} --require-size ${CKSIZE} ${args}"
		else
			_fetch_cmd="${dp_FETCH_CMD} ${args}"
		fi

		# Always - because ${dp_TARGET} is limited to (do-fetch|makesum)
		${dp_ECHO_MSG} "=> Attempting to fetch ${site}${file}"
		if env ${dp_FETCH_ENV} ${_fetch_cmd}; then
			chmod 644 "${download_path}"

			if [ -z "${dp_DISABLE_SIZE}" ]; then
				if [ "${dp_OPSYS}" = "Linux" ] || [ "${dp_OPSYS}" = "SunOS" ]; then
					actual_size=$(stat --printf=%s "${download_path}")
				else
					actual_size=$(stat -f %z "${download_path}")
				fi
				if [ "${actual_size}" -ne "${CKSIZE}" ]; then
					${dp_ECHO_MSG} "=> Fetched file size mismatch (expected ${CKSIZE}, actual ${actual_size})"
					rm -f "${download_path}"
					if [ ${sites_remaining} -gt 0 ]; then
						${dp_ECHO_MSG} "=> Trying next site"
					fi
					continue
				fi
			fi

			if [ -z "${dp_DISABLE_CHECKSUM}" ]; then
				downloadsum=$(/bin/sha256 < "${download_path}")
				if [ "${downloadsum}" != "${_sha256sum}" ]; then
					${dp_ECHO_MSG} "=> Downloaded file failed checksum verification"
					rm -f "${download_path}"
					if [ ${sites_remaining} -gt 0 ]; then
						${dp_ECHO_MSG} "=> Trying next site"
					fi
					continue
				fi
			fi

			# considered a good download.  Relocate to final destination
			mv "${download_path}" "${final_path}"
			rm -f "${lockfile}"
			continue 2
		fi
	done

	${dp_ECHO_MSG} "=> Unable to download ${file}"
	${dp_ECHO_MSG} "=> Try copying the file manually to ${dp_DISTDIR} and retry."
	rm -f "${lockfile}"
	exit 1
done
