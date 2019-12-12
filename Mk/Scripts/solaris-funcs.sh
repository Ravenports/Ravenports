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
#include <string.h>

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

snippet_getline()
{
	cat << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

static ssize_t
getdelim(char **buf, size_t *bufsiz, int delimiter, FILE *fp)
{
	char *ptr, *eptr;


	if (*buf == NULL || *bufsiz == 0) {
		*bufsiz = BUFSIZ;
		if ((*buf = malloc(*bufsiz)) == NULL)
			return -1;
	}

	for (ptr = *buf, eptr = *buf + *bufsiz;;) {
		int c = fgetc(fp);
		if (c == -1) {
			if (feof(fp))
				return ptr == *buf ? -1 : ptr - *buf;
			else
				return -1;
		}
		*ptr++ = c;
		if (c == delimiter) {
			*ptr = '\0';
			return ptr - *buf;
		}
		if (ptr + 2 >= eptr) {
			char *nbuf;
			size_t nbufsiz = *bufsiz * 2;
			ssize_t d = ptr - *buf;
			if ((nbuf = realloc(*buf, nbufsiz)) == NULL)
				return -1;
			*buf = nbuf;
			*bufsiz = nbufsiz;
			eptr = nbuf + nbufsiz;
			ptr = nbuf + d;
		}
	}
}

static ssize_t
getline(char **buf, size_t *bufsiz, FILE *fp)
{
	return getdelim(buf, bufsiz, '\n', fp);
}
EOF
} # snippet_getline

snippet_timegm()
{
	cat << 'EOF'
#include <time.h>
#include <errno.h>
#include <limits.h>
#include <sys/time.h>

static int
is_leapyear (int year_since_1900)
{
   int year = year_since_1900 + 1900;

   if (year % 4 == 0) {
      if (year % 100 == 0) {
         return (year % 400 == 0);
      }
      return (1);
   }
   return (0);
}

static unsigned
seconds_per_year (int year_since_1900)
{
   return (86400 * (is_leapyear(year_since_1900) ? 366 : 365));
}

#ifndef WRONG
#define WRONG	(-1)
#endif

static time_t
timegm(struct tm *const tmp)
{
	const unsigned days_past[2][12] = {
	  { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 },
	  { 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 },
        };
	struct tm	normalized = { 0 };
	long long int	result = 0;
	long long int	counterres;
	int		day_counter;
	int 		leapyear;
	int 		year;
	int		space_remains;
	int		spy;
	int		full_days;
	int		index;

	if (tmp == NULL) {
		errno = EINVAL;
		return WRONG;
	}

	result += tmp->tm_sec;
	result += tmp->tm_min * 60;
	result += tmp->tm_hour * 3600;

	/* handle negative month index or greater than 12 */
	if (tmp->tm_mon > 11) {
		year = tmp->tm_mon / 12;
		tmp->tm_mon -= (year * 12);
		tmp->tm_year += year;
	} else if (tmp->tm_mon < 0) {
		year = 1 + (tmp->tm_mon / -12);
		tmp->tm_mon += (year * 12);
		tmp->tm_year -= year;
	}

	leapyear = is_leapyear(tmp->tm_year);
	result += days_past[leapyear][tmp->tm_mon] * 86400;
	result += (tmp->tm_mday - 1) * 86400;
	for (year = tmp->tm_year; year < 70; year++)
		result -= seconds_per_year(year);
	for (year = 70; year < tmp->tm_year; year++)
		result += seconds_per_year(year);

	if (sizeof(result) > sizeof(time_t)) {
		if (result > INT_MAX || result < INT_MIN) {
			errno = EOVERFLOW;
			return WRONG;
		}
	}

	/* now normalize time structure */
	counterres = result;
	space_remains = 1;
	if (result >= 0) {
		normalized.tm_year = 70;
		/* 4 January 1970 was the first positive Sunday */
		day_counter = 4 + (result / 86400);
		normalized.tm_wday = day_counter % 7;

		while (space_remains) {
			spy = seconds_per_year(normalized.tm_year);
			if (counterres - spy < 0) {
				space_remains = 0;
			} else {
				normalized.tm_year += 1;
				counterres -= spy;
			}
		}
		leapyear = is_leapyear(normalized.tm_year);
	} else {
		/* Date prior to Jan 1, 1970 */
		normalized.tm_year = 69;
		/* 28 December 1969 was the first negative Sunday */
		day_counter = ((result + 1) / -86400) % 7;
		     if (day_counter == 0) normalized.tm_wday = 3;
		else if (day_counter == 1) normalized.tm_wday = 2;
		else if (day_counter == 2) normalized.tm_wday = 1;
		else if (day_counter == 3) normalized.tm_wday = 0;
		else if (day_counter == 4) normalized.tm_wday = 6;
		else if (day_counter == 5) normalized.tm_wday = 5;
		else                       normalized.tm_wday = 4;

		while (space_remains) {
			spy = seconds_per_year(normalized.tm_year);
			if (counterres + spy >= 0) {
				space_remains = 0;
			} else {
				normalized.tm_year -= 1;
				counterres += spy;
			}
		}
		/* what remains is a partial year.
		 * 1 = 31 DEC 23:59:59
		 * convert to positive track by adding full year to counterres
		 */
		leapyear = is_leapyear(normalized.tm_year);
		counterres += seconds_per_year (normalized.tm_year);
	}

	for (index = 11; index >= 0; index--) {
		spy = days_past[leapyear][index] * 86400;
		if (counterres - spy >= 0) {
			normalized.tm_mon = index;
			normalized.tm_yday = days_past[leapyear][index];
			counterres -= spy;
			break;
		}
	}
	full_days = (counterres / 86400);
	normalized.tm_mday = 1 + full_days;
	normalized.tm_yday += full_days;
	counterres -= (full_days * 86400);

	normalized.tm_hour = counterres / 3600;
	counterres -= (normalized.tm_hour * 3600);
	normalized.tm_min = counterres / 60;
	counterres -= (normalized.tm_min * 60);
	normalized.tm_sec = counterres;

	tmp->tm_year   = normalized.tm_year;
	tmp->tm_mon    = normalized.tm_mon;
	tmp->tm_mday   = normalized.tm_mday;
	tmp->tm_hour   = normalized.tm_hour;
	tmp->tm_min    = normalized.tm_min;
	tmp->tm_sec    = normalized.tm_sec;
	tmp->tm_yday   = normalized.tm_yday;
	tmp->tm_wday   = normalized.tm_wday;
	tmp->tm_isdst  = 0;
	return ((time_t) result);
}

EOF
} # snippet_timegm

snippet_strsep()
{
	cat << 'EOF'
#include <string.h>
#include <stdio.h>

static char *
strsep(char **stringp, const char *delim)
{
	char *s;
	const char *spanp;
	int c, sc;
	char *tok;

	if ((s = *stringp) == NULL)
		return (NULL);
	for (tok = s;;) {
		c = *s++;
		spanp = delim;
		do {
			if ((sc = *spanp++) == c) {
				if (c == 0)
					s = NULL;
				else
					s[-1] = 0;
				*stringp = s;
				return (tok);
			}
		} while (sc != 0);
	}
	/* NOTREACHED */
}

EOF
} # snippet_strsep


case "$1" in
	dirfd)    snippet_dirfd ;;
	mkdtemp)  snippet_mkdtemp ;;
	asprintf) snippet_asprintf ;;
	strnlen)  snippet_strnlen ;;
	strndup)  snippet_strndup ;;
	strsep)   snippet_strsep ;;
	getline)  snippet_getline ;;
	err.h)    snippet_err_h ;;
	timegm)   snippet_timegm ;;
	*) echo "Invalid selection (dirfd, mkdtemp, asprintf, strnlen, strsep"
	   echo "                   strndup, getline, err.h, timegm)"
	   ;;
esac
