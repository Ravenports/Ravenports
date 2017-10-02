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
# APQ
# ------------------------------------------------------------------------

APQ_VERSION=			3.2.0
APQ_BASE_REVISION=		0
APQ_MYSQL_REVISION=		0
APQ_PGSQL_REVISION=		0
APQ_ODBC_REVISION=		0

# ------------------------------------------------------------------------
# boost
# ------------------------------------------------------------------------

BOOST_VERSION=			1.65.1
BOOST_JAM_REVISION=		0
BOOST_LIBRARIES_REVISION=	0

# ------------------------------------------------------------------------
# gcc6
# ------------------------------------------------------------------------

GCC6_BRANCH=			6
GCC6_POINT=			4.0
GCC6_VERSION=			${GCC6_BRANCH}.${GCC6_POINT}
GCC6_SNAPSHOT=			20170704
GCC6_BUILD_RELEASE=		yes
GCC6_REVISION=			0
GCC6_GNAT_UTIL_REVISION=	0

.if ${GCC6_BUILD_RELEASE:Mno}
GCC6_PORTVERSION=		${GCC6_BRANCH}.${GCC6_SNAPSHOT}
GCC6_IDENTIFICATION=		gcc-${GCC6_BRANCH}-${GCC6_SNAPSHOT}
GCC6_MS_SUBDIR=			snapshots/${GCC6_BRANCH}-${GCC6_SNAPSHOT}
GCC6_PHASE=			snapshot
.else
GCC6_PORTVERSION=		${GCC6_VERSION}
GCC6_IDENTIFICATION=		gcc-${GCC6_VERSION}
GCC6_MS_SUBDIR=			releases/gcc-${GCC6_VERSION}
GCC6_PHASE=			release
.endif

# ------------------------------------------------------------------------
# gcc7
# ------------------------------------------------------------------------

GCC7_BRANCH=			7
GCC7_POINT=			2.0
GCC7_VERSION=			${GCC7_BRANCH}.${GCC7_POINT}
GCC7_SNAPSHOT=			20170814
GCC7_BUILD_RELEASE=		yes
GCC7_REVISION=			0
GCC7_GNAT_UTIL_REVISION=	0

.if ${GCC7_BUILD_RELEASE:Mno}
GCC7_PORTVERSION=		${GCC7_BRANCH}.${GCC7_SNAPSHOT}
GCC7_IDENTIFICATION=		gcc-${GCC7_BRANCH}-${GCC7_SNAPSHOT}
GCC7_MS_SUBDIR=			snapshots/${GCC7_BRANCH}-${GCC7_SNAPSHOT}
GCC7_PHASE=			snapshot
.else
GCC7_PORTVERSION=		${GCC7_VERSION}
GCC7_IDENTIFICATION=		gcc-${GCC7_VERSION}
GCC7_MS_SUBDIR=			releases/gcc-${GCC7_VERSION}
GCC7_PHASE=			release
.endif

# ------------------------------------------------------------------------
# icu
# ------------------------------------------------------------------------

ICU_VERSION=			59.1
ICU_REVISION=			0
ICU_LX_REVISION=		0

# ------------------------------------------------------------------------
# libxml2
# ------------------------------------------------------------------------

LIBXML2_VERSION=		2.9.5
LIBXML2_REVISION=		0
LIBXML2_PYTHON_REVISION=	0

# ------------------------------------------------------------------------
# libxslt
# ------------------------------------------------------------------------

LIBXSLT_VERSION=		1.1.30
LIBXSLT_REVISION=		0
LIBXSLT_PYTHON_REVISION=	1

# ------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------

RUBY_2.3_REVISION=		1
RUBY_2.3_PATCHLEVEL=		0

RUBY_2.4_REVISION=		0
RUBY_2.4_PATCHLEVEL=		0

# ------------------------------------------------------------------------
# gnome
# ------------------------------------------------------------------------

GTK2_VERSION=			2.10.0
GTK3_VERSION=			3.0.0
GTK2_PORT_VERSION=		2.24.31
GTK3_PORT_VERSION=		3.22.21

# ------------------------------------------------------------------------
# default gcc and binutils
# ------------------------------------------------------------------------

CURRENT_GCC=			gcc7
CURRENT_GCC_VERSION=		${GCC7_VERSION}
BINUTILS_VERSION=		2.29.1

# ------------------------------------------------------------------------
# aspell
# ------------------------------------------------------------------------

ASPELL_CORE_VERSION=		0.60.6.1

# ------------------------------------------------------------------------
# apr1 and other apache projects
# ------------------------------------------------------------------------

APR1_VERSION=			1.6.2
APR1_UTIL_VERSION=		1.6.0
SUBVERSION_VERSION=		1.9.7

# ------------------------------------------------------------------------
# Miscellaneous master versions
# ------------------------------------------------------------------------

LIBFM_VERSION=			1.2.5
FREI0R_VERSION=			1.6.1
M17N_VERSION=			1.7.0
GLIBC_VERSION=			2.26
