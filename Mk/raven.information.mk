# RESERVED_WARNING
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

BOOST_VERSION=			1.69.0
BOOST_JAM_REVISION=		0
BOOST_LIBRARIES_REVISION=	0

# ------------------------------------------------------------------------
# gcc6
# ------------------------------------------------------------------------

GCC6_BRANCH=			6
GCC6_POINT=			5.0
GCC6_VERSION=			${GCC6_BRANCH}.${GCC6_POINT}
GCC6_SNAPSHOT=			20181026
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
GCC7_POINT=			3.0
GCC7_VERSION=			${GCC7_BRANCH}.${GCC7_POINT}
GCC7_SNAPSHOT=			20180125
GCC7_BUILD_RELEASE=		yes
GCC7_REVISION=			1
GCC7_GNAT_UTIL_REVISION=	0
GCC7_GNATCROSS_REVISION=	0
GCC7_BOOTSTRAP_REVISION=	0

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
# gcc8
# ------------------------------------------------------------------------

GCC8_BRANCH=			8
GCC8_POINT=			2.0
GCC8_VERSION=			${GCC8_BRANCH}.${GCC8_POINT}
GCC8_SNAPSHOT=			20180726
GCC8_BUILD_RELEASE=		yes
GCC8_REVISION=			0
GCC8_GNAT_UTIL_REVISION=	0
GCC8_GNATCROSS_REVISION=	0
GCC8_BOOTSTRAP_REVISION=	0

.if ${GCC8_BUILD_RELEASE:Mno}
GCC8_PORTVERSION=		${GCC8_BRANCH}.${GCC8_SNAPSHOT}
GCC8_IDENTIFICATION=		gcc-${GCC8_BRANCH}-${GCC8_SNAPSHOT}
GCC8_MS_SUBDIR=			snapshots/${GCC8_BRANCH}-${GCC8_SNAPSHOT}
GCC8_PHASE=			snapshot
.else
GCC8_PORTVERSION=		${GCC8_VERSION}
GCC8_IDENTIFICATION=		gcc-${GCC8_VERSION}
GCC8_MS_SUBDIR=			releases/gcc-${GCC8_VERSION}
GCC8_PHASE=			release
.endif

# ------------------------------------------------------------------------
# icu
# ------------------------------------------------------------------------

ICU_VERSION=			63.1
ICU_REVISION=			0
ICU_LX_REVISION=		0

# ------------------------------------------------------------------------
# libxml2
# ------------------------------------------------------------------------

LIBXML2_VERSION=		2.9.9
LIBXML2_REVISION=		0
LIBXML2_PYTHON_REVISION=	0

# ------------------------------------------------------------------------
# libxslt
# ------------------------------------------------------------------------

LIBXSLT_VERSION=		1.1.33
LIBXSLT_REVISION=		0
LIBXSLT_PYTHON_REVISION=	0

# ------------------------------------------------------------------------
# ruby
# ------------------------------------------------------------------------

RUBY_2.3_REVISION=		0
RUBY_2.3_PATCHLEVEL=		0

RUBY_2.4_REVISION=		0
RUBY_2.4_PATCHLEVEL=		0

RUBY_2.5_REVISION=		0
RUBY_2.5_PATCHLEVEL=		0

RUBY_2.6_REVISION=		0
RUBY_2.6_PATCHLEVEL=		0

# ------------------------------------------------------------------------
# gnome
# ------------------------------------------------------------------------

GTK2_VERSION=			2.10.0
GTK3_VERSION=			3.0.0
GTK2_PORT_VERSION=		2.24.32
GTK3_PORT_VERSION=		3.24.4

# ------------------------------------------------------------------------
# default gcc and binutils
# ------------------------------------------------------------------------

CURRENT_GCC=			gcc8	# mirror in Uses/meson.mk
CURRENT_GCC_VERSION=		${GCC8_VERSION}
BINUTILS_VERSION=		2.31.1

# ------------------------------------------------------------------------
# aspell
# ------------------------------------------------------------------------

ASPELL_CORE_VERSION=		0.60.6.1

# ------------------------------------------------------------------------
# apr1 and other apache projects
# ------------------------------------------------------------------------

APR1_VERSION=			1.6.5
APR1_UTIL_VERSION=		1.6.1
SUBVERSION_VERSION=		1.11.1

# ------------------------------------------------------------------------
# Miscellaneous master versions
# ------------------------------------------------------------------------

LIBFM_VERSION=			1.3.1
LIBTOOL_VERSION=		2.4.6
FREI0R_VERSION=			1.6.1
M17N_VERSION=			1.8.0
GLIBC_VERSION=			2.26
GSTREAMER1_VERSION=		1.15.1
GSTREAMER1_GST=			1.0
GSTREAMER1_SOVERSION=		0.1501.0
XORG_VERSION=			7.7
FIREFOX52_VERSION=		52.9.0
FIREFOX_ESR_VERSION=		60.4.0
LLVM_VERSION=			7.0.1

# ------------------------------------------------------------------------
# Gnatcross options
# ------------------------------------------------------------------------

GNATCROSS_FREEBSD_11=		11.1
GNATCROSS_FREEBSD_12=		12.0

# ------------------------------------------------------------------------
# Qt and Lumina versions
# ------------------------------------------------------------------------

QT5_VERSION=			5.12.0
LUMINA_VERSION=			1.4.1
LUMINA_RELEASE_TAG=		b6536c1
