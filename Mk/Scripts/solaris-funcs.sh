#!/bin/sh
#
# Used by Uses/solaris-funcs.mk
# arg 1 values: dirfd, asprintf, mkdtemp, strnlen, strndup
#

snippet_dirfd()
{
	cat << 'EOF'
#include <dirent.h>

static int
dirfd(DIR *dirp) {
	return (dirp->dd_fd);
}

EOF
} # snippet_dirfd

snippet_mkdtemp()
{
	cat << 'EOF'
#include <stdlib.h>
#include <sys/stat.h>

static char *
mkdtemp(char *template) {
	if ((mktemp(template) == NULL) || (mkdir(template, 0700) != 0)) {
		return (NULL);
	} else {
		return (template);
	}
}

EOF
} # snippet_mkdtemp

snippet_asprintf()
{
	cat << 'EOF'
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <sys/varargs.h>

static int
vasprintf(char **strp, const char *fmt, va_list args)
{
    va_list args_copy;
    int status, needed;

    va_copy(args_copy, args);
    needed = vsnprintf(NULL, 0, fmt, args_copy);
    va_end(args_copy);
    if (needed < 0) {
        *strp = NULL;
        return (needed);
    }
    *strp = (char *)malloc(needed + 1);
    if (*strp == NULL)
        return (-1);
    status = vsnprintf(*strp, needed + 1, fmt, args);
    if (status >= 0)
        return (status);
    else {
        free(*strp);
        *strp = NULL;
        return (status);
    }
}

static int
asprintf(char **strp, const char *fmt, ...)
{
    va_list args;
    int status;

    va_start(args, fmt);
    status = vasprintf(strp, fmt, args);
    va_end(args);
    return (status);
}

EOF
} # snippet_asprintf

snippet_strnlen()
{
	cat << 'EOF'
#include <string.h>

static size_t
strnlen(const char *s, size_t maxlen)
{
       size_t len;
       for (len = 0; len < maxlen; len++, s++) {
               if (!*s) break;
       }
       return (len);
}

EOF
} # snippet_strnlen

snippet_strndup()
{
	cat << 'EOF'
#include <stdlib.h>
#include <string.h>

static char *
strndup(const char *str, size_t n)
{
    size_t len;
    char *copy;

    len = strlen(str);
    if (len <= n)
        return (strdup(str));
    if ((copy = (char *)malloc(len + 1)) == NULL)
        return (NULL);
    memcpy(copy, str, len);
    copy[len] = '\0';
    return (copy);
}

EOF
} # snippet_strndup

snippet_err_h()
{
	cat << 'EOF'
#ifndef BSD_ERR_H
#define BSD_ERR_H

#define __printflike(x, y) __attribute((format(printf, (x), (y))))
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <stdarg.h>

#define err(exitcode, format, args...) \
	errx(exitcode, format ": %s", ## args, strerror(errno))
#define errx(exitcode, format, args...) \
	{ warnx(format, ## args); exit(exitcode); }
#define warn(format, args...) \
	warnx(format ": %s", ## args, strerror(errno))
#define warnx(format, args...) \
	fprintf(stderr, format "\n", ## args)

static void warnc(int code, const char *format, ...)
	__printflike(2, 3);
static void vwarn(const char *format, va_list ap)
	__printflike(1, 0);
static void vwarnc(int code, const char *format, va_list ap)
	__printflike(2, 0);
static void errc(int status, int code, const char *format, ...)
	__printflike(3, 4);
static void verr(int status, const char *format, va_list ap)
	__printflike(2, 0);
static void verrc(int status, int code, const char *format, va_list ap)
	__printflike(3, 0);

static void
vwarn(const char *fmt, va_list ap)
{
	vwarnc(errno, fmt, ap);
}

static void
verr(int eval, const char *fmt, va_list ap)
{
	verrc(eval, errno, fmt, ap);
}

static void
warnc(int code, const char *format, ...)
{
	va_list ap;

	va_start(ap, format);
	vwarnc(code, format, ap);
	va_end(ap);
}

static void
vwarnc(int code, const char *format, va_list ap)
{
	if (format) {
		vfprintf(stderr, format, ap);
		fprintf(stderr, ": ");
	}
	fprintf(stderr, "%s\n", strerror(code));
}

static void
errc(int status, int code, const char *format, ...)
{
	va_list ap;

	va_start(ap, format);
	verrc(status, code, format, ap);
	va_end(ap);
}

static void
verrc(int status, int code, const char *format, va_list ap)
{
	if (format) {
		vfprintf(stderr, format, ap);
		fprintf(stderr, ": ");
	}
	fprintf(stderr, "%s\n", strerror(code));
	exit(status);
}

#endif
EOF
}

case "$1" in
	dirfd)    snippet_dirfd ;;
	mkdtemp)  snippet_mkdtemp ;;
	asprintf) snippet_asprintf ;;
	strnlen)  snippet_strnlen ;;
	strndup)  snippet_strndup ;;
	err.h)    snippet_err_h ;;
	*) echo "Invalid selection (dirfd, mkdtemp, asprintf, strnlen, strndup, err.h)" ;;
esac
