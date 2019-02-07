# Handle dependency on the gettext-runtime (libintl) port
#
# Feature:	gettext-runtime
# Usage:	USES=gettext-runtime or USES=gettext-runtime:ARGS
# Valid ARGS:	buildrun (default), build, run, asprintf
#

.if !defined(_INCLUDE_USES_GETTEXT_RUNTIME_MK)
_INCLUDE_USES_GETTEXT_RUNTIME_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
# if ARGS :build (but not :run, :buildrun)
# BUILD_DEPENDS+=	gettext:runtime:standard
# -----------------------------------------------------
# if ARGS are none or contain :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   gettext:runtime:standard
# -----------------------------------------------------
# if ARGS contains :run (and not :build, :buildrun)
# RUN_DEPENDS+=        gettext:runtime:standard
# -----------------------------------------------------
# if ARGS contains :asprintf
#    and :build (but not :run, :buildrun)
# BUILD_DEPENDS+=      gettext:asprintf:standard
# -----------------------------------------------------
# if ARGS contains :asprintf
#    and :buildrun (or :build and :run)
# BUILDRUN_DEPENDS+=   gettext:asprintf:standard
# -----------------------------------------------------
# if ARGS contains :asprintf
#    and :run (but not :build or :buildrun)
# RUN_DEPENDS+=        gettext:asprintf:standard
# -----------------------------------------------------

# for cargo support (only in effect with USES=cargo)
CARGO_ENV+=	GETTEXT_BIN_DIR=${LOCALBASE}/bin \
		GETTEXT_INCLUDE_DIR=${LOCALBASE}/include \
		GETTEXT_LIB_DIR=${LOCALBASE}/lib

.endif
