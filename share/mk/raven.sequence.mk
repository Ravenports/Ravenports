# This is the final logic which controls the build sequence.
# This is very similar to FreeBSD Ports Collection sequence logic.

# The order of _TARGET_STAGES is signficant.
# Consider returning SANITY stage if required

_TARGETS_STAGES=	FETCH EXTRACT PATCH CONFIGURE BUILD INSTALL TEST \
			PACKAGE STAGE

# --------------------------------------------------------------------------
# --  Sequence definition
# --------------------------------------------------------------------------

# Define the SEQ of actions to take when each target is run, and which targets
# they depend on before executing its SEQ.
#
# The main target has a priority of 500, pre-target priority is 300,
# post-target priority is 700, and target-depends has a priority of 150.
# The remaining targets are slotted according to sequence requirements.

_FETCH_DEP=		# none currently
_FETCH_SEQ=		150:fetch-depends \
			300:pre-fetch \
			450:pre-fetch-script \
			500:do-fetch \
			700:post-fetch \
			850:post-fetch-script \
			${_OPTIONS_fetch} \
			${_USES_fetch}

_EXTRACT_DEP=		fetch
_EXTRACT_SEQ=		050:extract-message \
			100:checksum \
			150:extract-depends \
			190:clean-wrkdir \
			200:${EXTRACT_WRKDIR} \
			300:pre-extract \
			400:pre-extract-opsys \
			450:pre-extract-script \
			500:do-extract \
			600:apply-slist \
			700:post-extract \
			750:post-extract-opsys \
			850:post-extract-script \
			999:extract-fixup-modes \
			${_OPTIONS_extract} \
			${_USES_extract} \
			${_SITES_extract}

_PATCH_DEP=		extract
_PATCH_SEQ=		100:patch-message \
			150:patch-depends \
			300:pre-patch \
			400:pre-patch-opsys \
			450:pre-patch-script \
			500:do-patch \
			700:post-patch \
			750:post-patch-opsys \
			850:post-patch-script \
			${_OPTIONS_patch} \
			${_USES_patch}

_CONFIGURE_DEP=		patch
_CONFIGURE_SEQ=		150:build-depends \
			155:lib-depends \
			200:configure-message \
			300:pre-configure \
			400:pre-configure-opsys \
			450:pre-configure-script \
			475:run-autotools-fixup \
			500:do-configure \
			700:post-configure \
			750:post-configure-opsys \
			850:post-configure-script \
			${_OPTIONS_configure} \
			${_USES_configure}

_BUILD_DEP=		configure
_BUILD_SEQ=		100:build-message \
			300:pre-build \
			400:pre-build-opsys \
			450:pre-build-script \
			500:do-build \
			700:post-build \
			750:post-build-opsys \
			850:post-build-script \
			${_OPTIONS_build} \
			${_USES_build}

# STAGE is special in its numbering as it has install and stage,
# so install is the main, and stage goes after.

_STAGE_DEP=		build
_STAGE_SEQ=		050:stage-message \
			100:stage-dir \
			150:run-depends \
			155:lib-depends \
			300:pre-install \
			350:pre-install-opsys \
			400:generate-plist \
			450:create-users-groups \
			500:do-install \
			700:post-install \
			725:post-install-opsys \
			750:post-install-script \
			800:post-stage \
			850:compress-man \
			860:install-rc-script \
			870:install-smf-manifest \
			880:install-license \
			890:install-desktop-entries \
			900:add-plist-info \
			910:add-plist-docs \
			920:add-plist-examples \
			930:add-plist-post \
			${POST_PLIST_TARGET:C/^/990:/} \
			995:stage-qa \
			${_OPTIONS_install} \
			${_USES_install} \
			${_OPTIONS_stage} \
			${_USES_stage}

_TEST_DEP=		stage
_TEST_SEQ=		100:test-message \
			150:test-depends \
			300:pre-test \
			500:do-test \
			800:post-test \
			${_OPTIONS_test} \
			${_USES_test}

_INSTALL_DEP=		stage
_INSTALL_SEQ=		100:install-message \
			150:run-depends \
			151:lib-depends \
			200:check-already-installed \
			300:fake-pkg \
			500:security-check

_PACKAGE_DEP=		stage
_PACKAGE_SEQ=		100:package-message \
			300:pre-package \
			450:pre-package-script \
			500:do-package \
			850:post-package-script \
			${_OPTIONS_package} \
			${_USES_package}

# --------------------------------------------------------------------------
# --  Target ordering
# --------------------------------------------------------------------------

# Enforce order for -jN builds
.for _t in ${_TARGETS_STAGES}
.  for s in ${_${_t}_SEQ:O:C/^[0-9]+://}
.    if target(${s})
_PHONY_TARGETS+=	${s}
_${_t}_REAL_SEQ+=	${s}
.    endif
.  endfor
.ORDER: ${_${_t}_DEP} ${_${_t}_REAL_SEQ}
.endfor

# --------------------------------------------------------------------------
# --  pre-* and post-script targets
# --------------------------------------------------------------------------

.for subphase in pre post
.  for name in pkg fetch extract patch configure build install package
.    if exists(${SCRIPTDIR}/${subphase}-${name})
.      if !target(${subphase}-${name}-script)
${subphase}-${name}-script:
	@cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} \
		${SH} ${SCRIPTDIR}/${subphase}-${name}
.      endif
.    endif
.  endfor
.endfor

# --------------------------------------------------------------------------
# --  Phase target definition
# --------------------------------------------------------------------------

# Define all of the main targets which depend on a sequence of other targets.
# See above *_SEQ and *_DEP. The _DEP will run before this defined target is
# ran. The _SEQ will run as this target once _DEP is satisfied.

# Names of cookies used to skip already completed stages

EXTRACT_COOKIE=		${WRKDIR}/.done_extract
PATCH_COOKIE=		${WRKDIR}/.done_patch
CONFIGURE_COOKIE=	${WRKDIR}/.done_configure
BUILD_COOKIE=		${WRKDIR}/.done_build
STAGE_COOKIE=		${WRKDIR}/.done_stage
INSTALL_COOKIE=		${WRKDIR}/.done_install
PACKAGE_COOKIE=		${WRKDIR}/.done_package

# Disable build
.if defined(NO_BUILD)
build: configure
	@${TOUCH} ${TOUCH_FLAGS} ${BUILD_COOKIE}
.endif

# Disable test
.if defined(NO_TEST)
test: stage
	@${DO_NADA}
.endif

# Disable package
.if defined(NO_PACKAGE)
package:
.  if defined(IGNORE_SILENT)
	@${DO_NADA}
.  else
	@${ECHO_MSG} "===>  ${TWO_PART_ID} may not be packaged: "${NO_PACKAGE:Q}.
.  endif
.endif

.for target in extract patch configure build stage install package

.  if !target(${target})
_PHONY_TARGETS+= ${target}
${target}: ${${target:tu}_COOKIE}
.  endif

.  if exists(${${target:tu}_COOKIE})
${${target:tu}_COOKIE}::
	if [ -e ${.TARGET} ]; then \
		${DO_NADA}; \
	else \
		cd ${.CURDIR} && ${MAKE} ${.TARGET}; \
	fi
.  else
${${target:tu}_COOKIE}: ${_${target:tu}_DEP} ${_${target:tu}_REAL_SEQ}
	@${TOUCH} -f ${.TARGET}
.  endif

.endfor # foreach(targets)

.for target in fetch pkg test
.  if !target(${target})
_PHONY_TARGETS+= ${target}
${target}: ${_${target:tu}_DEP} ${_${target:tu}_REAL_SEQ}
.  endif
.endfor

.PHONY: ${_PHONY_TARGETS}

# --------------------------------------------------------------------------
# --  Special Targets
# --------------------------------------------------------------------------

.if !target(restage)
restage:
	@${RM} -r ${STAGEDIR} ${STAGE_COOKIE} ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
	@cd ${.CURDIR} && ${MAKE} stage
.endif

.if !target(reinstall)
reinstall:
	@${RM} ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
	@cd ${.CURDIR} && DEPENDS_TARGET="${DEPENDS_TARGET}" ${MAKE} -DFORCE_PKG_REGISTER install
.endif
