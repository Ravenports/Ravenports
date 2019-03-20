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
    *strp = malloc(needed + 1);
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

case "$1" in
	dirfd)    snippet_dirfd ;;
	mkdtemp)  snippet_mkdtemp ;;
	asprintf) snippet_asprintf ;;
	strnlen)  snippet_strnlen ;;
	strndup)  snippet_strndup ;;
	*) echo "Invalid selection (dirfd, mkdtemp, asprintf, strnlen, strndup)" ;;
esac
