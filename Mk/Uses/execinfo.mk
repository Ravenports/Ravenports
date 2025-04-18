# handle dependency on the libexecinfo library
#
# Feature:	execinfo
# Usage:	USES=execinfo
# Valid ARGS:	buildrun (implicit), build

.if !defined(_INCLUDE_USES_EXECINFO_MK)
_INCLUDE_USES_EXECINFO_MK=	yes

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
#.if ${zstd_ARGS:Mbuild}
# BUILD_DEPENDS+=	libexecinfo:dev:std
#.else
# BUILD_DEPENDS+=	libexecinfo:dev:std
# BUILDRUN_DEPENDS+=	libexecinfo:primary:std
#.endif
#
# NOTE: On Darwin, this module is a no-op.
#       libexec requires ELF-formatted files,
#       while MacOS uses Mach-O format
# -----------------------------------------------

.endif
