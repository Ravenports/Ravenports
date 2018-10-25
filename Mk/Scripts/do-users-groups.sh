#!/bin/sh
# This script is specific to FreeBSD/DragonFly/Linux/Solaris/MacOS
# This script will need augmentation for other OS.

set -e

. "${dp_SCRIPTSDIR}/functions.sh"

validate_env dp_ECHO_MSG dp_GID_FILES dp_GID_OFFSET dp_INSTALL dp_OPSYS \
	dp_OSVERSION dp_PREFIX dp_PW dp_SCRIPTSDIR dp_UG_DEINSTALL \
	dp_UG_INSTALL dp_UID_FILES dp_UID_OFFSET dp_SYSTEM_UID dp_SYSTEM_GID

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_DO_USERS_GROUPS}" ] && set -x

set -u

# Do not use GROUPS as a variable name, it's reserved by bash!

SYSUSERS=$1
SYSGROUPS=$2

error() {
	${dp_ECHO_MSG} "${1}"

	exit 1
}

USERS_BLACKLIST=$(awk -F":" '!/^#/ {if (NF) print $1}' ${dp_SYSTEM_UID})
GROUP_BLACKLIST=$(awk -F":" '!/^#/ {if (NF) print $1}' ${dp_SYSTEM_GID})
GROUP_SEARCH_PROG="'{if (\$1 == name) found=1} END {exit found?0:1}'"
SUNOS_GROUPLIST_PROG="'\
{n=split(\$4,ray,\"(\");\
 for (x=2; x<=n; x++) {\
  j=split(ray[x], tray, \")\");\
  if (tray[1] == newgroup) { seen=1 };\
  g++; answer[g] = tray[1];\
 };\
 if (!seen && newgroup != \"\") { g++; answer[g] = newgroup };\
}\
END \
{result=answer[1];\
 for (x=2; x<=g; x++) { result = result \",\" answer[x] };\
 printf (\"%s\\n\", result);\
}'"

rm -f "${dp_UG_INSTALL}" "${dp_UG_DEINSTALL}" || :

echo "PW=${dp_PW}" >> "${dp_UG_INSTALL}"


# Both scripts need to start the same, so
cp -f "${dp_UG_INSTALL}" "${dp_UG_DEINSTALL}"

if [ -n "${SYSGROUPS}" ]; then
	for file in ${dp_GID_FILES}; do
		if [ ! -f "${file}" ]; then
			error "** ${file} doesn't exist. Exiting."
		fi
	done
	${dp_ECHO_MSG} "===> Creating groups."
	echo "echo \"===> Creating groups.\"" >> "${dp_UG_INSTALL}"
	for group in ${SYSGROUPS}; do
	    if ! echo "${GROUP_BLACKLIST}" | grep -qw "${group}"; then
		# _bgpd:*:130:
		oneline=$(grep -h -m 1 "^${group}:" ${dp_GID_FILES}) || \
			error "** Cannot find any information about group \`${group}' in ${dp_GID_FILES}."
		o_IFS=${IFS}
		IFS=":"
		while read -r group _ gid _; do
			if [ -z "${gid}" ]; then
				error "Group line for group ${group} has no gid"
			fi
			gid=$((gid+dp_GID_OFFSET))
			if [ "${dp_OPSYS}" = "Linux" -o "${dp_OPSYS}" = "SunOS" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "Using existing group '$group'."
else
  echo "Creating group '$group' with gid '$gid'."
  groupadd -g $gid $group
fi
eot2
			elif [ "${dp_OPSYS}" = "Darwin" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
if [ -z "\${RAVENADM}" ]; then
  if dscl . read /Groups/$group RecordName >/dev/null 2>&1; then
    PGID=\$(dscl . -read /Groups/$group PrimaryGroupID | awk '{print \$2}')
    echo "Using existing group '$group' (PrimaryGroupID: \${PGID})."
  else
    echo "Creating group '$group' with gid '$gid'."
    dscl . -create /Groups/$group
    dscl . -create /Groups/$group PrimaryGroupID $gid
    PGID=$gid
  fi
else
  echo "TESTING: skip group '$group' creation (requires OpenDirectory service)"
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
		${oneline}
		eot
		IFS=${o_IFS}
	    fi
	done
fi

if [ -n "${SYSUSERS}" ]; then
	for file in ${dp_UID_FILES}; do
		if [ ! -f "${file}" ]; then
			error "** ${file} doesn't exist. Exiting."
		fi
	done

	${dp_ECHO_MSG} "===> Creating users"
	echo "echo \"===> Creating users\"" >> "${dp_UG_INSTALL}"

	for user in ${SYSUSERS}; do
	    if ! echo "${USERS_BLACKLIST}" | grep -qw "${user}"; then
	        # Format of Mk/Templates/UID.ravenports
	        # smmsp:*:25:smmsp::0:0:Sendmail Submission User:/var/spool/clientmqueue:/usr/sbin/nologin
	        oneline=$(grep -h -m 1 "^${user}:" ${dp_UID_FILES}) || \
			error "** Cannot find any information about user \`${user}' in ${dp_UID_FILES}."
		o_IFS=${IFS}
		IFS=":"
		while read -r login _ uid group class _ _ gecos homedir shell; do
			if [ -z "$uid" ] || [ -z "$group" ] || [ -z "$homedir" ] || [ -z "$shell" ]; then
				error "User line for ${user} is invalid"
			fi
			uid=$((uid+dp_UID_OFFSET))
			if [ -n "$class" ]; then
				class="-L $class"
			fi
			if [ "${dp_OPSYS}" = "SunOS" -a "$shell" = "/usr/sbin/nologin" ]; then
				shell="/usr/bin/false"
			fi
			homedir=$(echo "$homedir" | sed "s|^LOCALBASE/|${dp_PREFIX}/|")
			cat >> "${dp_UG_INSTALL}" <<-eot2
if id ${user} >/dev/null 2>&1; then
  echo "Using existing user '$login'."
else
  echo "Creating user '$login' with uid '$uid', member of $group group."
eot2
			if [ "${dp_OPSYS}" = "Linux" -o "${dp_OPSYS}" = "SunOS" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
  useradd -u $uid -g $group $class -c "$gecos" -d $homedir -s $shell $login
fi
eot2
			elif [ "${dp_OPSYS}" = "Darwin" ]; then
				cat >> "${dp_UG_INSTALL}" <<-eot2
  if [ -z "\${RAVENADM}" ]; then
    dscl . -create /Users/$login
    dscl . -create /Users/$login UniqueID $uid
    dscl . -create /Users/$login PrimaryGroupID \${PGID}
    dscl . -create /Users/$login RealName '$gecos'
    dscl . -create /Users/$login NFSHomeDirectory $homedir
    dscl . -create /Users/$login UserShell $shell
  else
    echo "TESTING: skip user '$login' creation (requires OpenDirectory service)"
  fi
fi
eot2
			else
				cat >> "${dp_UG_INSTALL}" <<-eot2
  \${PW} useradd $login -u $uid -g $group $class -c "$gecos" -d $homedir -s $shell
fi
eot2
			fi
			case $homedir in
				/|/nonexistent|/var/empty)
					;;
				*)
					if [ "${dp_OPSYS}" = "SunOS" ]; then
					  echo "mkdir -p $homedir" >> "${dp_UG_INSTALL}"
					  echo "chown $login:$group $homedir" >> "${dp_UG_INSTALL}"
					elif [ "${dp_OPSYS}" = "Darwin" ]; then
					  cat >> "${dp_UG_INSTALL}" <<-eot2
if [ -z "\${RAVENADM}" ]; then
  ${dp_INSTALL} -d -g $group -o $login $homedir
else
  echo "TESTING: skip home directory '$homedir' creation"
fi
eot2
					else
					  echo "${dp_INSTALL} -d -g $group -o $login $homedir" >> "${dp_UG_INSTALL}"
					fi
					;;
			esac
		done <<-eot
		${oneline}
		eot
		IFS=${o_IFS}
	    fi
	done
fi

if [ -n "${SYSGROUPS}" ]; then
	for sysgroup in ${SYSGROUPS}; do
		# mail:*:6:postfix,clamav
		oneline=$(grep -h -m 1 "^${sysgroup}:" ${dp_GID_FILES}) || \
			error "** Cannot find $sysgroup group in ${dp_UID_FILES}. Perhaps it exists only on blacklist?"
		o_IFS=${IFS}
		IFS=":"
		while read -r group _ gid members; do
			oo_IFS=${IFS}
			IFS=","
			for login in $members; do
				for user in ${SYSUSERS}; do
					if [ -n "${user}" ] && [ "${user}" = "${login}" ]; then
						if [ "${dp_OPSYS}" = "Linux" ]; then
							cat >> "${dp_UG_INSTALL}" <<-eot2
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "Adding user '${login}' to group '${group}'."
  usermod -a -G ${group} ${login}
fi
eot2
						elif [ "${dp_OPSYS}" = "SunOS" ]; then
							cat >> "${dp_UG_INSTALL}" <<-eot2
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "Adding user '${login}' to group '${group}'."
  group_list=`id -a ${login} | awk -F'=' -vnewgroup=${group} ${SUNOS_GROUPLIST_PROG}`
  usermod -G ${group_list} ${login}
fi
eot2
						elif [ "${dp_OPSYS}" = "Darwin" ]; then
							cat >> "${dp_UG_INSTALL}" <<-eot2
if [ -z "\${RAVENADM}" ]; then
  if dscl . read /Groups/$group RecordName >/dev/null 2>&1; then
    if dscl . -list /Groups/$group GroupMembership | tr ' ' '\n' | awk -v name=\"$group\" ${GROUP_SEARCH_PROGRAM} >/dev/null 2>&1; then
      echo "User '$login' is already a member of group '$group', doing nothing."
    else
      echo "Adding user '$login' as a member of group '$group'."
      dscl . -append /Groups/$group GroupMembership $login
    fi
  fi
else
  echo "TESTING: skip adding user '$login' to group '$group' (requires OpenDirectory service)"
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
		${oneline}
		eot
		IFS=${o_IFS}
	done
fi

if [ -n "${SYSUSERS}" ]; then
	for user in ${SYSUSERS}; do
		if ! echo "${USERS_BLACKLIST}" | grep -qw "${user}"; then
			cat >> "${dp_UG_DEINSTALL}" <<-eot
if id ${user} >/dev/null 2>&1; then
  echo "==> You should manually remove the \"${user}\" user. "
fi
eot
		fi
	done
fi

if [ -n "${SYSGROUPS}" ]; then
	for group in ${SYSGROUPS}; do
		if ! echo "${GROUP_BLACKLIST}" | grep -qw "${group}"; then
			if [ "${dp_OPSYS}" = "Linux" -o "${dp_OPSYS}" = "SunOS" ]; then
				cat >> "${dp_UG_DEINSTALL}" <<-eot
if awk -F':' -vname=\"${group}\" ${GROUP_SEARCH_PROG} /etc/group >/dev/null 2>&1; then
  echo "==> You should manually remove the \"${group}\" group "
fi
eot
			elif [ "${dp_OPSYS}" = "Darwin" ]; then
				cat >> "${dp_UG_DEINSTALL}" <<-eot
if [ -z "\${RAVENADM}" ]; then
  if dscl . read /Groups/$group RecordName >/dev/null 2>&1; then
    echo "==> You should manually remove the \"${group}\" group "
  fi
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
