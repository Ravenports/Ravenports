# Handle dependency on PERL 5.x
#
# Feature:     perl
# Usage:       USES=perl
# Valid ARGS:  configure (implies build & run)
#              buildmod (implies build, do not use with buildmodtiny)
#              buildmodtiny (implies build, do not use with buildmod)
#              run (do not use with configure)
#              none (just sets BUILDRUN_DEPENDS) 
#
# Internal ravenadm makefile may preset this variable:
# PERL5_DEFAULT
#
# The makefile sets the following variables:
# PERL_VERSION   - Full version of perl5
# PERL_VER       - Short version of perl5 (major.minor without patchlevel)
# PERL5	         - Set to full path of perl5
# PERL	         - Set to full path of perl5, but without version number.
#                  Use this if you need to replace "#!" lines in scripts.
# SITE_PERL      - Absolute path to directory where site-specific perl
#                  packages go.  Added to PLIST_SUB as SITE_PERL_REL
# SITE_PERL_REL  - Same as SITE_PERL, but relative to LOCALBASE
# SITE_ARCH      - Absolute path to directory where arch-specific perl
#                  packages go.  Added to PLIST_SUB as SITE_ARCH_REL
# SITE_ARCH_REL  - Same as SITE_ARCH, but relative to LOCALBASE
# SITE_MAN1      - Absolute path to site-specific man1 pages
#                  Added to PLIST_SUB as SITE_MAN1_REL
# SITE_MAN1_REL  - Same as SITE_MAN1, but relative to LOCALBASE
# SITE_MAN3      - Absolute path to site-specific man3 pages
#                  Added to PLIST_SUB as SITE_MAN3_REL
# SITE_MAN3_REL  - Same as SITE_MAN3, but relative to LOCALBASE
# PERL_ARCH      - Directory name of architecture dependent libraries
# SITE_PERL      - Directory name where site specific perl packages go.
#                  This value is added to PLIST_SUB.
#

.if !defined(_INCLUDE_USES_PERL_MK)
_INCLUDE_USES_PERL_MK=	yes

PERL_VERSION=	${PERL_${PERL5_DEFAULT}_VERSION}
PERL_VER=	${PERL_VERSION:C/\.[0-9]+$//}
PERL_ARCH=	mach

SITE_PERL_REL=	lib/perl5/site_perl
SITE_PERL=	${LOCALBASE}/${SITE_PERL_REL}
SITE_ARCH_REL=	${SITE_PERL_REL}/${PERL_ARCH}/${PERL_VER}
SITE_ARCH=	${LOCALBASE}/${SITE_ARCH_REL}
SITE_MAN1_REL=	${SITE_PERL_REL}/man/man1
SITE_MAN1=	${PREFIX}/${SITE_MAN1_REL}
SITE_MAN3_REL=	${SITE_PERL_REL}/man/man3
SITE_MAN3=	${PREFIX}/${SITE_MAN3_REL}

PERL5=		${LOCALBASE}/bin/perl${PERL_VERSION}
PERL=		${LOCALBASE}/bin/perl
MANDIRS+=	${PREFIX}/${SITE_PERL_REL}/man

CONFIGURE_ENV+=	ac_cv_path_PERL=${PERL} \
		ac_cv_path_PERL_PATH=${PERL} \
		PERL_USE_UNSAFE_INC=1
MAKE_ENV+=	PERL_USE_UNSAFE_INC=1

PLIST_SUB+=	PERL_VERSION=${PERL_VERSION} \
		PERL_VER=${PERL_VER} \
		PERL5_MAN1=${SITE_MAN1_REL} \
		PERL5_MAN3=${SITE_MAN3_REL} \
		SITE_PERL=${SITE_PERL_REL} \
		SITE_ARCH=${SITE_ARCH_REL}

# --------------------------------------------------------------------------
# --  Configure
# --------------------------------------------------------------------------

.  if ${perl_ARGS:Mconfigure}

# Disable AutoInstall from attempting to install from CPAN directly in
# the case of missing dependencies.  This causes the build to loop on
# the build cluster asking for interactive input.

CONFIGURE_SCRIPT?=	Makefile.PL
CONFIGURE_ENV+=		PERL_EXTUTILS_AUTOINSTALL="--skipdeps" \
			PERL_MM_USE_DEFAULT="YES"
CONFIGURE_ARGS+=	CC="${CC}" \
			CCFLAGS="${CFLAGS}" \
			PREFIX="${PREFIX}" \
			INSTALLPRIVLIB="${PREFIX}/lib" \
			INSTALLARCHLIB="${PREFIX}/lib" \
			INSTALLDIRS="site"
MAN1PREFIX=		${PREFIX}/${SITE_PERL_REL}
MAN3PREFIX=		${PREFIX}/${SITE_PERL_REL}

.    if !target(do-configure)
do-configure:
	@if [ -f ${SCRIPTDIR}/configure ]; then \
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH} \
		${SCRIPTDIR}/configure; \
	fi
	@cd ${CONFIGURE_WRKSRC} && \
		${SETENV} ${CONFIGURE_ENV} \
		${PERL5} ${CONFIGURE_CMD} ${CONFIGURE_ARGS}
.      if !${perl_ARGS:Mbuildmod*}
	@cd ${CONFIGURE_WRKSRC} && \
		${PERL5} -pi -e 's/ doc_(perl|site|\$$\(INSTALLDIRS\))_install$$//' Makefile
.      endif	# buildmod* not in ARGS
.    endif	# !target(do-configure)
.  endif	# configure in ARGS

# --------------------------------------------------------------------------
# --  buildmod and buildmodtiny
# --------------------------------------------------------------------------

.  if ${perl_ARGS:Mbuildmod*}

BUILD_TARGET?=		# empty
CONFIGURE_ARGS+=	--install_path lib="${PREFIX}/${SITE_PERL_REL}" \
			--install_path arch="${PREFIX}/${SITE_ARCH_REL}" \
			--install_path script="${PREFIX}/bin" \
			--install_path bin="${PREFIX}/bin" \
			--install_path libdoc="${MAN3PREFIX}/man/man3" \
			--install_path bindoc="${MAN1PREFIX}/man/man1"
CONFIGURE_SCRIPT?=	Build.PL
PL_BUILD?=		Build
CONFIGURE_ARGS+=	--destdir ${STAGEDIR}
DESTDIRNAME=		--destdir

.    if ${perl_ARGS:Mbuildmod}
CONFIGURE_ARGS+=	--perl="${PERL}" \
			--create_packlist 1                 
.    endif	# buildmod in ARGS

.    if ${perl_ARGS:Mbuildmodtiny}
CONFIGURE_ARGS+=	--create_packlist 1
.    endif	# buildmodtiny in ARGS

.    if !target(do-build)
do-build:
	@(cd ${BUILD_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${PERL5} ${PL_BUILD} ${ALL_TARGET} ${MAKE_ARGS})
.    endif	# !target(do-build)

.    if !${USES:Mgmake}
.      if !target(do-install)
do-install:
	@(cd ${BUILD_WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${PERL5} ${PL_BUILD} ${INSTALL_TARGET} ${MAKE_ARGS})
.      endif	# !target(do-install)
.    endif 	# ! USES=gmake
.  end		# buildmod* in ARGS

# --------------------------------------------------------------------------
# --  Test
# --------------------------------------------------------------------------

.  if !target(do-test) && \
	(!empty(perl_ARGS:Mbuildmod*) || !empty(perl_ARGS:Mconfigure))

TEST_TARGET?=	test
TEST_WRKSRC?=	${BUILD_WRKSRC}

do-test:
.    if ${perl_ARGS:Mbuildmod*}
	(cd ${TEST_WRKSRC}/ && ${SETENV} ${TEST_ENV} \
		${PERL5} ${PL_BUILD} ${TEST_TARGET} ${TEST_ARGS})
.    elif ${perl_ARGS:Mconfigure}
	(cd ${TEST_WRKSRC}/ && ${SETENV} ${TEST_ENV} \
		${MAKE_CMD} ${TEST_ARGS} ${TEST_TARGET})
.    endif
.  endif	# !target(do-test) plus ...

# --------------------------------------------------------------------------
# --  fix-perl-things target
# --------------------------------------------------------------------------

_USES_install+=	560:fix-perl-things

fix-perl-things:
	# Remove STAGEDIR from .packlist and add the file to the plist.
	# perl packages are always solitary, with the subpackage name of
	# "single"

	@(if [ -d ${STAGEDIR}${PACKLIST_DIR} ] ; then \
		${FIND} ${STAGEDIR}${PACKLIST_DIR} -name .packlist | while read f ; do \
			${SED} -i '' 's|^${STAGEDIR}||' "$$f"; \
			${ECHO} $$f | ${SED} -e 's|^${STAGEDIR}||' \
			>> ${WRKDIR}/.manifest.single.mktmp; \
		done \
	fi) || :

	# Starting with perl 5.20, the empty bootstrap files are not
	# installed any more by ExtUtils::MakeMaker.  As we don't need them
	# anyway, remove them.  Module::Build continues to install them, so
	# remove the files unconditionally.

	@${FIND} ${STAGEDIR} -name '*.bs' -size 0 -delete || :

	# Some ports use their own way of building perl modules and generate
	# perllocal.pod, remove it here so that those ports don't include it
	# by mistake in their plists.  It is sometime compressed, so use a
	# shell glob for the removal.  Also, remove the directories that
	# contain it to not leave orphans directories around.

	@${RM} ${STAGEDIR}${PREFIX}/lib/perl5/${PERL_VER}/${PERL_ARCH}/perllocal.pod* || :
	@${RMDIR} -p ${STAGEDIR}${PREFIX}/lib/perl5/${PERL_VER}/${PERL_ARCH} 2>/dev/null || :

	# Starting at ExtUtils::MakeMaker 7.06 and Perl 5.25.1, the base
	# README.pod is no longer manified into a README.3, as the README.pod
	# is installed and can be read with perldoc, remove the README.3 files
	# that may be generated.

	@[ -d "${STAGEDIR}${SITE_MAN3}" ] && \
		${FIND} ${STAGEDIR}${SITE_MAN3} -name '*::README.3' -delete || :

# --------------------------------------------------------------------------
# --  ravenadm logic
# --------------------------------------------------------------------------

# if perl_ARGS contain ("buildmod" or "buildmodtiny"), but not "run":
# BUILD_DEPENDS+=	perl${PERL5_DEFAULT}:primary:standard
#
# if perl_ARGS contain "run" and "buildmod" or "buildmodtiny"):
# BUILDRUN_DEPENDS+=	perl${PERL5_DEFAULT}:primary:standard
#
# if perl ARGS contain only "configure" or are empty.
# BUILDRUN_DEPENDS+=	perl${PERL5_DEFAULT}:primary:standard
#
# if perl_ARGS contain only "run"
# RUN_DEPENDS+=		perl${PERL5_DEFAULT}:primary:standard
#
# if perl_ARGS contain "buildmod"
# BUILD_DEPENDS+=	p5-Module-Build:primary:standard
#
# if perl_ARGS contain "buildmodtiny"
# BUILD_DEPENDS+=	p5-Module-Build-Tiny:primary:standard
#

.endif	# defined(_INCLUDE_USES_PERL_MK)