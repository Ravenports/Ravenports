#!/bin/sh
# This script is specific to FreeBSD/DragonFly
# This script will need augmentation for other OS.

set -e

. "${dp_SCRIPTSDIR}/functions.sh"

validate_env dp_ECHO_MSG dp_GID_FILES dp_GID_OFFSET dp_INSTALL dp_OPSYS \
	dp_OSVERSION dp_PREFIX dp_PW dp_SCRIPTSDIR dp_UG_DEINSTALL \
	dp_UG_INSTALL dp_UID_FILES dp_UID_OFFSET dp_SYSTEM_UID dp_SYSTEM_GID

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_DO_USERS_GROUPS}" ] && set -x

set -u

USERS=$1
GROUPS=$2

error() {
	${dp_ECHO_MSG} "${1}"

	exit 1
}

USERS_BLACKLIST=$(awk -F":" '!/^#/ {if (NF) print $1}' ${dp_SYSTEM_UID})
GROUP_BLACKLIST=$(awk -F":" '!/^#/ {if (NF) print $1}' ${dp_SYSTEM_GID})
GROUP_SEARCH_PROG="'{if (\$1 == name) found=1} END {exit found?0:1}'"

rm -f "${dp_UG_INSTALL}" "${dp_UG_DEINSTALL}" || :

echo "PW=${dp_PW}" >> "${dp_UG_INSTALL}"


# Both scripts need to start the same, so
cp -f "${dp_UG_INSTALL}" "${dp_UG_DEINSTALL}"

if [ -n "${GROUPS}" ]; then
	for file in ${dp_GID_FILES}; do
		if [ ! -f "${file}" ]; then
			error "** ${file} doesn't exist. Exiting."
		fi
	done
	${dp_ECHO_MSG} "===> Creating groups."
	echo "echo \"===> Creating groups.\"" >> "${dp_UG_INSTALL}"
	for group in ${GROUPS}; do
	    if ! echo "${GROUP_BLACKLIST}" | grep -qw "${group}"; then
		# _bgpd:*:130:
		if ! grep -q "^${group}:" ${dp_GID_FILES}; then \
			error "** Cannot find any information about group \`${group}' in ${dp_GID_FILES}."
		fi
		o_IFS=${IFS}
		IFS=":"
		while read -r group _ gid _; do
			if [ -z "${gid}" ]; then
				error "Group line for group ${group} has no gid"
			fi
			gid=$((gid+dp_GID_OFFSET))
			if [ "${dp_OPSYS}" = "Linux" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "Using existing group '$group'."
else
  echo "Creating group '$group' with gid '$gid'."
  groupadd -g $gid $group
fi
eot2
			else
				cat >> "${dp_UG_INSTALL}" <<-eot2
if ! \${PW} groupshow $group >/dev/null 2>&1; then
  echo "Creating group '$group' with gid '$gid'."
  \${PW} groupadd $group -g $gid
else
  echo "Using existing group '$group'."
fi
eot2
			fi
		done <<-eot
		$(grep -h "^${group}:" ${dp_GID_FILES} | head -n 1)
		eot
		IFS=${o_IFS}
	    fi
	done
fi

if [ -n "${USERS}" ]; then
	for file in ${dp_UID_FILES}; do
		if [ ! -f "${file}" ]; then
			error "** ${file} doesn't exist. Exiting."
		fi
	done

	${dp_ECHO_MSG} "===> Creating users"
	echo "echo \"===> Creating users\"" >> "${dp_UG_INSTALL}"

	for user in ${USERS}; do
	    if ! echo "${USERS_BLACKLIST}" | grep -qw "${user}"; then
	        # Format of Mk/Templates/UID.<opsys> (No login class for Linux, enforced manually)
	        # smmsp:*:25:25::0:0:Sendmail Submission User:/var/spool/clientmqueue:/usr/sbin/nologin
		if ! grep -q "^${user}:" ${dp_UID_FILES} ; then
			error "** Cannot find any information about user \`${user}' in ${dp_UID_FILES}."
		fi
		o_IFS=${IFS}
		IFS=":"
		while read -r login _ uid gid class _ _ gecos homedir shell; do
			if [ -z "$uid" ] || [ -z "$gid" ] || [ -z "$homedir" ] || [ -z "$shell" ]; then
				error "User line for ${user} is invalid"
			fi
			uid=$((uid+dp_UID_OFFSET))
			gid=$((gid+dp_GID_OFFSET))
			if [ -n "$class" ]; then
				class="-L $class"
			fi
			homedir=$(echo "$homedir" | sed "s|^LOCALBASE/|${dp_PREFIX}/|")
			cat >> "${dp_UG_INSTALL}" <<-eot2
if id ${user} >/dev/null 2>&1; then
  echo "Using existing user '$login'."
else
  echo "Creating user '$login' with uid '$uid'."
eot2
			if [ "${dp_OPSYS}" = "Linux" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
  useradd -u $uid -g $gid $class -c "$gecos" -d $homedir -s $shell $login
fi
eot2
			else
				cat >> "${dp_UG_INSTALL}" <<-eot2
  \${PW} useradd $login -u $uid -g $gid $class -c "$gecos" -d $homedir -s $shell
fi
eot2
			fi
			case $homedir in
				/|/nonexistent|/var/empty)
					;;
				*)
					group=$(awk -F: -v gid=${gid} '$3 == gid { print $1 }' ${dp_GID_FILES})
					echo "${dp_INSTALL} -d -g $group -o $login $homedir" >> "${dp_UG_INSTALL}"
					;;
			esac
		done <<-eot
		$(grep -h "^${user}:" ${dp_UID_FILES} | head -n 1)
		eot
		IFS=${o_IFS}
	    fi
	done
fi

if [ -n "${GROUPS}" ]; then
	for group in ${GROUPS}; do
		# mail:*:6:postfix,clamav
		o_IFS=${IFS}
		IFS=":"
		while read -r group _ gid members; do
			gid=$((gid+dp_GID_OFFSET))
			oo_IFS=${IFS}
			IFS=","
			for login in $members; do
				for user in ${USERS}; do
					if [ -n "${user}" ] && [ "${user}" = "${login}" ]; then
						if [ "${dp_OPSYS}" = "Linux" ]; then
							cat >> "${dp_UG_INSTALL}" <<-eot2
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "Adding user '${login}' to group '${group}'."
  usermod -a -G ${group} ${login}
fi
eot2
						else
							cat >> "${dp_UG_INSTALL}" <<-eot2
if ! \${PW} groupshow ${group} | grep -qw ${login}; then
  echo "Adding user '${login}' to group '${group}'."
  \${PW} groupmod ${group} -m ${login}
fi
eot2
						fi
					fi
				done
			done
			IFS=${oo_IFS}
		done <<-eot
		$(grep -h "^${group}:" ${dp_GID_FILES} | head -n 1)
		eot
		IFS=${o_IFS}
	done
fi

if [ -n "${USERS}" ]; then
	for user in ${USERS}; do
		if ! echo "${USERS_BLACKLIST}" | grep -qw "${user}"; then
			cat >> "${dp_UG_DEINSTALL}" <<-eot
if id ${user} >/dev/null 2>&1; then
  echo "==> You should manually remove the \"${user}\" user. "
fi
eot
		fi
	done
fi

if [ -n "${GROUPS}" ]; then
	for group in ${GROUPS}; do
		if ! echo "${GROUP_BLACKLIST}" | grep -qw "${group}"; then
			if [ "${dp_OPSYS}" = "Linux" ]; then
				cat >> "${dp_UG_DEINSTALL}" <<-eot
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "==> You should manually remove the \"${group}\" group "
fi
eot
			else
				cat >> "${dp_UG_DEINSTALL}" <<-eot
if \${PW} groupshow ${group} >/dev/null 2>&1; then
  echo "==> You should manually remove the \"${group}\" group "
fi
eot
			fi
		fi
	done
fi
