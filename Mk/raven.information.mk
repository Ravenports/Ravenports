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

BOOST_VERSION=			1.64.0
BOOST_JAM_REVISION=		0
BOOST_LIBRARIES_REVISION=	0

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

# ------------------------------------------------------------------------
# icu
# ------------------------------------------------------------------------

ICU_VERSION=			59.1
ICU_REVISION=			0
ICU_LX_REVISION=		0

# ------------------------------------------------------------------------
# libxml2
# ------------------------------------------------------------------------

LIBXML2_VERSION=		2.9.4
LIBXML2_REVISION=		0
LIBXML2_PYTHON_REVISION=	0

# ------------------------------------------------------------------------
# libxslt
# ------------------------------------------------------------------------

LIBXSLT_VERSION=		1.1.29
LIBXSLT_REVISION=		0
LIBXSLT_PYTHON_REVISION=	0

# ------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------

RUBY_2.3_REVISION=		0
RUBY_2.3_PATCHLEVEL=		0

RUBY_2.4_REVISION=		0
RUBY_2.4_PATCHLEVEL=		0

# ------------------------------------------------------------------------
# gnome
# ------------------------------------------------------------------------

GTK2_VERSION=			2.10.0
GTK3_VERSION=			3.0.0

# ------------------------------------------------------------------------
# default gcc
# ------------------------------------------------------------------------

CURRENT_GCC=			gcc6
