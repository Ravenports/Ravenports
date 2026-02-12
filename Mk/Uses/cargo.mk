# Handle building rust applications using the cargo command
#
# Feature:      cargo
# Usage:        USES=cargo
# valid ARGS:   none
#
# CARGO_FEATURES     List of features to build (space separated list)
# CARGO_VENDOR_DIR   Name of the local directory for vendoring crates
# CARGO_CARGOTOML    Default path for cargo TOML file
# CARGO_CARGOLOCK    Default path for cargo LOCK file
# CARGO_CARGO_BIN    Location of cargo binary
# CARGO_TARGET_DIR   Location of the cargo output directory
# CARGO_BUILD_TARGET Either "release" or "debug"
#
# Environment for cargo (CARGO_ENV)
#  - CARGO_HOME: local cache of the registry index
#  - CARGO_BUILD_JOBS: configure number of jobs to run
#  - CARGO_TARGET_DIR: location of where to place all generated artifacts
#  - RUSTC: path of rustc binary (default to lang/rust)
#  - RUSTDOC: path of rustdoc binary (default to lang/rust)
#  - RUSTFLAGS: custom flags to pass to all compiler invocations that Cargo performs
#
# Switch to use targets defined here (default: "no", override with "yes")
# CARGO_SKIP_CONFIGURE	do-configure target
# CARGO_SKIP_BUILD	do-build target
# CARGO_SKIP_INSTALL	do-install target
#
# User arguments for cargo targets (default blank)
# CARGO_CONFIG_ARGS    for do-configure target
# CARGO_BUILD_ARGS     for do-build target
# CARGO_INSTALL_ARGS   for do-install target
#

CARGO_VENDOR_DIR?=	${WRKSRC}/cargo-crates
CARGO_CARGOTOML?=	${WRKSRC}/Cargo.toml
CARGO_CARGOLOCK?=	${WRKSRC}/Cargo.lock
CARGO_CARGO_BIN?=	${LOCALBASE}/bin/cargo
CARGO_TARGET_DIR?=	${WRKDIR}/target
CARGO_SKIP_CONFIGURE?=	no
CARGO_SKIP_BUILD?=	no
CARGO_SKIP_INSTALL?=	no
CARGO_FEATURES?=
CARGO_BUILD_ARGS?=
CARGO_INSTALL_ARGS?=
CARGO_TEST_ARGS?=
CARGO_CONFIG_ARGS?=

# -----------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------
# BUILD_DEPENDS+=	rust:single:std
# -----------------------------------------------

# Augments CARGO_ENV (taking care not to override)
.if empty(${CARGO_ENV:MCARGO_HOME=*})
CARGO_ENV+=	CARGO_HOME=${WRKDIR}/cargo-home
.endif
.if empty(${CARGO_ENV:MCARGO_BUILD_JOBS=*})
CARGO_ENV+=	CARGO_BUILD_JOBS=${MAKE_JOBS_NUMBER}
.endif
.if empty(${CARGO_ENV:MCARGO_TARGET_DIR=*})
CARGO_ENV+=	CARGO_TARGET_DIR=${CARGO_TARGET_DIR}
.endif
.if empty(${CARGO_ENV:MRUSTC=*})
CARGO_ENV+=	RUSTC=${LOCALBASE}/bin/rustc
.endif
.if empty(${CARGO_ENV:MRUSTDOC=*})
CARGO_ENV+=	RUSTDOC=${LOCALBASE}/bin/rustdoc
.endif
.if empty(${CARGO_ENV:MRUSTFLAGS=*})
CARGO_ENV+=	RUSTFLAGS="${RUSTFLAGS} -C linker=${CC:Q} ${LDFLAGS:S/^/-C link-arg=/}"
.endif

# Helper to shorten cargo calls.
CARGO_CARGO_RUN= \
	cd ${WRKSRC} && ${SETENVI} ${MAKE_ENV} ${CARGO_ENV} ${CARGO_CARGO_BIN}

# Manage crate features.
.if !empty(CARGO_FEATURES)
CARGO_BUILD_ARGS+=	--features='${CARGO_FEATURES}'
CARGO_INSTALL_ARGS+=	--features='${CARGO_FEATURES}'
CARGO_TEST_ARGS+=	--features='${CARGO_FEATURES}'
.endif

.if !defined(WITH_DEBUG)
CARGO_BUILD_ARGS+=	--release
CARGO_TEST_ARGS+=	--release
CARGO_BUILD_TARGET=	release
.else
CARGO_INSTALL_ARGS+=	--debug
CARGO_BUILD_TARGET=	debug
.endif

# always use system versions over bundled
CARGO_ENV+=	LIBGIT2_SYS_USE_PKG_CONFIG=1 \
		LIBSSH2_SYS_USE_PKG_CONFIG=1 \
		RUSTONIG_SYSTEM_LIBONIG=1

# Support sccache if present.
# The primary program to use is /usr/bin/sccache, which will be in place if the
# platforms system root includes it.  The backup location is $LOCALBASE/bin/sccache
SCCACHE1=/usr/bin/sccache
SCCACHE2=/raven/bin/sccache
.if defined(BUILD_WITH_CCACHE)
. if exists(${SCCACHE1}) || exists(${SCCACHE2})
.  if exists(${SCCACHE1})
CARGO_ENV+=	RUSTC_WRAPPER=${SCCACHE1}
.  else
CARGO_ENV+=	RUSTC_WRAPPER=${SCCACHE2}
.  endif
CARGO_ENV+=	SCCACHE_DIR=${CCACHE_DIR}/sccache
. endif
.endif


.if !target(do-configure) && ${CARGO_SKIP_CONFIGURE:tl} == "no"
# configure hook.  Place a config file for overriding crates-io index
# by local source directory.
do-configure:
	@${ECHO_MSG} "===>   Cargo config:"
	@${MKDIR} ${WRKDIR}/.cargo
	@: > ${WRKDIR}/.cargo/config.toml
	@${ECHO_CMD} "[source.cargo]" >> ${WRKDIR}/.cargo/config.toml
	@${ECHO_CMD} "directory = '${CARGO_VENDOR_DIR}'" >> ${WRKDIR}/.cargo/config.toml
	@${ECHO_CMD} "[source.crates-io]" >> ${WRKDIR}/.cargo/config.toml
	@${ECHO_CMD} "replace-with = 'cargo'" >> ${WRKDIR}/.cargo/config.toml
	@${CAT} ${WRKDIR}/.cargo/config.toml

	@if ! ${GREP} -qF '[profile.release]' ${CARGO_CARGOTOML}; then \
		${ECHO_CMD} "" >> ${CARGO_CARGOTOML}; \
		${ECHO_CMD} "[profile.release]" >> ${CARGO_CARGOTOML}; \
		${ECHO_CMD} "opt-level = 2" >> ${CARGO_CARGOTOML}; \
		${ECHO_CMD} "debug = false" >> ${CARGO_CARGOTOML}; \
	fi
	@${ECHO_MSG} "===>   Updating Cargo.lock"
	${CARGO_CARGO_RUN} update \
		--manifest-path ${CARGO_CARGOTOML} \
		--verbose \
		${CARGO_CONFIG_ARGS}
.endif

.if !target(do-build) && ${CARGO_SKIP_BUILD:tl} == "no"
do-build:
	${CARGO_CARGO_RUN} build \
		--manifest-path ${CARGO_CARGOTOML} \
		--verbose \
		${CARGO_BUILD_ARGS}
.endif

.if !target(do-install) && ${CARGO_SKIP_INSTALL:tl} == "no"
do-install:
	${CARGO_CARGO_RUN} install \
		--path . \
		--root "${STAGEDIR}${PREFIX}" \
		--verbose \
		${CARGO_INSTALL_ARGS}
	${RM} -- "${STAGEDIR}${PREFIX}/.crates.toml"

.  if !defined(WITH_DEBUG)
	@flist=$$(${FIND} ${STAGEDIR}/ -type f -perm /111 -print) ;\
	if [ -n "$$flist" ]; then \
	   for f in $$flist; do \
	      (${FILE} $$f | ${GREP} -Fq ", not stripped")\
	      && ${ECHO_CMD} "Auto-stripping $$f"\
              && ${STRIP_CMD} $$f || ${TRUE} ;\
	   done ;\
	fi
.  endif
.endif
