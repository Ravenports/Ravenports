# This module sets up a post-install Lua script.
# The purpose of the script is to check if the NSS root certificate is
# installed in the raven tree.  If it is, nothing is done.
#
# However, if the certificate is absent, the script will print a
# message recommending that the user install the nss~caroot~std package
# which contains the certificate.
#
# This supports removing nss~caroot~std as a dependency for everything
# which allows for frequent updates without requiring rebuilds on
# heavy ports such as rust.
#
# Feature:	rootca
# Usage:	USES=rootca
# Valid ARGS:	subpackage (at least one required)
#

.if !defined(_INCLUDE_USES_ROOTCA_MK)
_INCLUDE_USES_CPE_MK=    yes

_USES_extract+=		655:rootca-check

.  if !target(rootca-check)
rootca-check:
	@allscripts="${_SCRIPT_FILE}.${rootca_ARGS}" ;\
	${CAT} ${MK_SCRIPTS}/rootca-check.lua >> $${allscripts}
.  endif

.endif
