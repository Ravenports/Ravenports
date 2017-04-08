# This file is not directly used by the Raven framework.
# It's sole purpose is to provide definitions that multiple specifications
# need in a single location.  The data is extracted by using the
# EXTRACT_INFO function on a specification definition, e.g.
#
# DEF[PORTVERSION]=		EXTRACT_INFO(GCC6_VERSION)
# 
# This file is only used at "compile-time", that is when the port
# specification is used to generate the buildsheet.

# ------------------------------------------------------------------------
# gcc6
# ------------------------------------------------------------------------

GCC6_BRANCH=			6
GCC6_POINT=			3.1
GCC6_VERSION=			${GCC6_BRANCH}.${GCC6_POINT}
GCC6_SNAPSHOT=			20170202
GCC6_BUILD_RELEASE=		no
GCC6_PORTVERSION=		${GCC6_BRANCH}.${GCC6_SNAPSHOT}
GCC6_REVISION=			0
GCC6_GNAT_UTIL_REVISION=	0

.if ${GCC6_BUILD_RELEASE:Mno}
GCC6_PORTVERSION=		${GCC6_BRANCH}.${GCC6_SNAPSHOT}
GCC6_IDENTIFICATION=		gcc-${GCC6_BRANCH}-${GCC6_SNAPSHOT}
GCC6_MS_SUBDIR=			snapshots/${GCC6_BRANCH}-${GCC6_SNAPSHOT}
GCC6_PHASE=			snapshot
.else
GCC6_IDENTIFICATION=		gcc-${GCC6_VERSION}
GCC6_MS_SUBDIR=			releases/gcc-${GCC6_VERSION}
GCC6_PHASE=			release
.endif
