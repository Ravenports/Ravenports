# sys.mk required by bmake

.SUFFIXES:	.out .o .c .cc .cpp .cxx .C .y .l .S .s .sh

AR?=		ar
AS?=		as
.if ${.MAKE.OS.NAME:MDarwin}
CC?=		gcc
CXX?=		g++
.else
CC?=		cc
CXX?=		c++
.endif
CC_LINK?=	${CC}
CXX_LINK?=	${CXX}
CPP?=		cpp
ECHO?=		echo
INSTALL?=	install
LEX?=		lex
LD?=		ld
MAKE?=		make
SHELL?=		sh

.sh:
	cp -p ${.IMPSRC} ${.TARGET}
	chmod a+x ${.TARGET}

.c:
	${CC} ${_${.IMPSRC:T}_FLAGS} ${CFLAGS} ${LDFLAGS} ${.IMPSRC} ${LDLIBS} -o ${.TARGET}

.c.o:
	${CC} ${_${.IMPSRC:T}_FLAGS} ${CFLAGS} -c ${.IMPSRC}

.cc .cpp .cxx .C:
	${CXX} ${_${.IMPSRC:T}_FLAGS} ${CXXFLAGS} ${LDFLAGS} ${.IMPSRC} ${LDLIBS} -o ${.TARGET}

.cc.o .cpp.o .cxx.o .C.o:
	${CXX} ${_${.IMPSRC:T}_FLAGS} ${CXXFLAGS} -c ${.IMPSRC}

.S.o:
	${CC} ${_${.IMPSRC:T}_FLAGS} ${CFLAGS} -c ${.IMPSRC}

.s.o:
	${AS} ${_${.IMPSRC:T}_FLAGS} ${AFLAGS} -o ${.TARGET} ${.IMPSRC}

# XXX not -j safe
.y.o:
	${YACC:Uyacc -d} ${YFLAGS} ${.IMPSRC}
	${CC} ${CFLAGS} -c y.tab.c -o ${.TARGET}
	rm -f y.tab.c

.l.o:
	${LEX} -t ${LFLAGS} ${.IMPSRC} > ${.PREFIX}.tmp.c
	${CC} ${CFLAGS} -c ${.PREFIX}.tmp.c -o ${.TARGET}
	rm -f ${.PREFIX}.tmp.c

# XXX not -j safe
.y.c:
	${YACC} ${YFLAGS} ${.IMPSRC}
	mv y.tab.c ${.TARGET}

.l.c:
	${LEX} -t ${LFLAGS} ${.IMPSRC} > ${.TARGET}

.s.out .c.out .o.out:
	${CC} ${_${.IMPSRC:T}_FLAGS} ${CFLAGS} ${LDFLAGS} ${.IMPSRC} ${LDLIBS} -o ${.TARGET}

# XXX not -j safe
.y.out:
	${YACC:Uyacc -d} ${YFLAGS} ${.IMPSRC}
	${CC} ${CFLAGS} ${LDFLAGS} y.tab.c ${LDLIBS} -ly -o ${.TARGET}
	rm -f y.tab.c

.l.out:
	${LEX} -t ${LFLAGS} ${.IMPSRC} > ${.PREFIX}.tmp.c
	${CC} ${CFLAGS} ${LDFLAGS} ${.PREFIX}.tmp.c ${LDLIBS} -ll -o ${.TARGET}
	rm -f ${.PREFIX}.tmp.c

.if exists(/etc/make.conf)
.include "/etc/make.conf"
.endif

# Tell bmake to expand -V VAR by default
.MAKE.EXPAND_VARIABLES?= yes
