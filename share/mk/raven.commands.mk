# raven.command.mk - Command commands used within the Ravenports
# infrastructure

.if !defined(_INCLUDE_CMD_MK)
_INCLUDE_CMD_MK=    yes

AWK=		/usr/bin/awk
BASENAME=	/usr/bin/basename
BZCAT=		/usr/bin/bzcat
BZIP2=		/usr/bin/bzip2
CAT=		/bin/cat
CHGRP=		/usr/bin/chgrp
CHMOD=		/bin/chmod
CHOWN=		/usr/bin/chown
COMM=		/usr/bin/comm
CP=		/usr/bin/cp
CPIO=		/usr/bin/cpio
CUT=		/usr/bin/cut
DIFF=		/usr/bin/diff
DIRNAME=	/usr/bin/dirname
ECHO_CMD=	echo	# shell builtin
ECHO_MSG?=	${ECHO_CMD}
EGREP=		/usr/bin/egrep
EXPR=		/bin/expr
FALSE=		false	# shell builtin
FETCH=		/usr/bin/fetch
FETCH_CMD=	${FETCH} -Fpr
FILE=		/usr/bin/file
FIND=		/usr/bin/find
FLEX=		/usr/bin/flex
GREP=		/usr/bin/grep
GUNZIP_CMD=	/usr/bin/gunzip -f
GZCAT=		/usr/bin/gzcat
GZIP_LEVEL?=	-9
GZIP_CMD=	/usr/bin/gzip -nf ${GZIP_LEVEL}
HEAD=		/usr/bin/head
ID=		/usr/bin/id
IDENT=		/usr/bin/ident
LN=		/bin/ln
LS=		/bin/ls
MD5=		/bin/md5
MKDIR=		/bin/mkdir -p
MKTEMP=		/usr/bin/mktemp
MV=		/bin/mv
PATCH=		/usr/bin/patch
PAX=		/bin/pax
REALPATH=	/bin/realpath
RM=		/bin/rm -f
RMDIR=		/bin/rmdir
SED=		/usr/bin/sed
SETENV=		/usr/bin/env
SH=		/bin/sh
SHA256=		/bin/sha256
SORT=		/usr/bin/sort
STRIP_CMD=	/usr/bin/strip
TAIL=		/usr/bin/tail
TEST=		test	# shell builtin
TOUCH=		/usr/bin/touch
TR=		/usr/bin/tr
TRUE=		true	# shell builtin
TAR=		/usr/bin/tar
UNAME=		/usr/bin/uname
UNZIP_CMD=	/usr/bin/unzip
WHICH=		/usr/bin/which
XARGS=		/usr/bin/xargs
YACC=		/usr/bin/yacc
XZ_LEVEL?=	-Mmax
XZCAT=		/usr/bin/xzcat ${XZ_LEVEL}
XZ_CMD=		/usr/bin/xz ${XZ_LEVEL}

.endif