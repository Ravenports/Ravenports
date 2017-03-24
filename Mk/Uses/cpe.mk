# Include CPE information in package manifest as a CPE 2.3 formatted
# string.  See http://scap.nist.gov/specifications/cpe/ for details.
#
# CPE_PART		Defaults to "a" for "application".
# CPE_VENDOR		Defaults to same as ${CPE_PRODUCT} (below).
# CPE_PRODUCT		Defaults to ${PORTNAME}.
# CPE_VERSION		Defaults to ${PORTVERSION}.
# CPE_UPDATE		Defaults to empty.
# CPE_EDITION		Defaults to empty.
# CPE_LANG		Defaults to empty.
# CPE_SW_EDITION	Defaults to empty.
# CPE_TARGET_SW		Defaults to the operating system name and version
# CPE_TARGET_HW		Defaults to x86 for i386, x64 for amd64, and
#			otherwise ${ARCH}.
# CPE_OTHER		Defaults to ${PORTREVISION} if non-zero.
#

.if !defined(_INCLUDE_USES_CPE_MK)
_INCLUDE_USES_CPE_MK=    yes

# The logic is contained in ravenadm.
# The presence of USES=cpe turns it on.

.endif
