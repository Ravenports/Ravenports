# handle dependencies that vary between BSD and non-BSD platforms.
# 
# Feature:      bsd
# Usage:        USES=bsd:ARGS
# Valid ARGS:   epoll, inotify, udev -or- gudev
#
# Buildsheet will fail to compile if no arguments are provided,
# or if both udev and gudev are provided.  Multiple argument
# definitions are fine.
#

.if !defined(_INCLUDE_USES_BSD_MK)
_INCLUDE_USES_BSD_MK=	yes

# -----------------------------------------------------
# Incorporated in ravenadm
# -----------------------------------------------------
#.if opsys in ["freebsd", "dragonfly", "netbsd", "midnightbsd", "openbsd"] 
#
#.  if ${bsd_ARGS:Mepoll}
# BUILD_DEPENDS+=	libepoll-shim:dev:std
#.  else
# BUILD_DEPENDS+=	libepoll-shim:dev:std
# BUILDRUN_DEPENDS+=	libepoll-shim:primary:std
#.  endif
#
#.  if ${bsd_ARGS:Minotify}
# BUILD_DEPENDS+=	libinotify:dev:std
#.  else
# BUILD_DEPENDS+=	libinotify:dev:std
# BUILDRUN_DEPENDS+=	libinotify:primary:std
#.  endif
#
#.  if ${bsd_ARGS:Mudev}
# BUILD_DEPENDS+=	libudev-devd:dev:std
#.  else
# BUILD_DEPENDS+=	libudev-devd:dev:std
# BUILDRUN_DEPENDS+=	libudev-devd:primary:std
#.  endif
#
#.  if ${bsd_ARGS:Mgudev}
# BUILD_DEPENDS+=	libgudev-devd:dev:std
#.  else
# BUILD_DEPENDS+=	libgudev-devd:dev:std
# BUILDRUN_DEPENDS+=	libgudev-devd:primary:std
#.  endif
#
#.else                   # ====== NON-BSD BELOW =====
#
#.  if ${bsd_ARGS:Mgudev}
# BUILD_DEPENDS+=	libgudev:dev:std
#.  else
# BUILD_DEPENDS+=	libgudev:dev:std
# BUILDRUN_DEPENDS+=	libgudev:primary:std
#.  endif
#
#.endif
# -----------------------------------------------------

.endif
