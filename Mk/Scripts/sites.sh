#!/bin/sh

set -e

if [ -n "${DEBUG_MK_SCRIPTS:-}" ] || [ -n "${DEBUG_MK_SCRIPTS_DO_FETCH:-}" ]; then
    set -x
fi
set -u

# Global (used in more than one expansion)
apache_cluster="\
  	http://www.apache.org/dist \
	http://archive.apache.org/dist \
	http://ftp.twaren.net/Unix/Web/apache \
	http://ftp.mirrorservice.org/sites/ftp.apache.org \
	http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist \
	http://mirrors.ircam.fr/pub/apache"

# Join a base URL and an optional subdirectory, avoiding doubled separators.
site_directory_url()
{
    local base="${1%/}"
    local subdir="${2%/}"
    printf '%s\n' "${base}${subdir:+/${subdir}}/"
}

# keep in order

expand_APACHE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##APACHE/}"
    local site
    for site in ${apache_cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_APACHE_COMMONS_BINARIES()
{
    # pattern [element]/commons/%SUBDIR%/binaries/
    # note: differs from FreeBSD ports
    local SUBDIR="${1##APACHE_COMMONS_BINARIES/}"
    local site
    for site in ${apache_cluster}; do
	printf '%s\n' "${site}/commons/${SUBDIR}/binaries/"
    done
}

expand_APACHE_COMMONS_SOURCE()
{
    # pattern [element]/commons/%SUBDIR%/source/
    # note: differs from FreeBSD ports
    local SUBDIR="${1##APACHE_COMMONS_SOURCE/}"
    local site
    for site in ${apache_cluster}; do
	printf '%s\n' "${site}/commons/${SUBDIR}/source/"
    done
}

expand_APACHE_HTTPD()
{
    # pattern [element]/httpd/%SUBDIR%/
    local SUBDIR="${1##APACHE_HTTPD/}"
    local site
    for site in ${apache_cluster}; do
	site_directory_url "${site}/httpd" "${SUBDIR}"
    done
}

expand_APACHE_JAKARTA()
{
    # pattern [element]/jakarta/%SUBDIR%/
    local SUBDIR="${1##APACHE_JAKARTA/}"
    local site="http://archive.apache.org/dist"
    site_directory_url "${site}/jakarta" "${SUBDIR}"
}

expand_SOURCEFORGE()
{
    # pattern [element]/%SUBDIR%/
    # note: differs from FreeBSD ports
    local SUBDIR;
    if [ "${2}" -eq 1 ]; then
	SUBDIR=${1##SOURCEFORGE/}
    else
    	SUBDIR=${1##SF/}
    fi
    local cluster="\
    http://freefr.dl.sourceforge.net/project \
    http://netix.dl.sourceforge.net/project \
    http://excellmedia.dl.sourceforge.net/project"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_GNU()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##GNU/}"
    local cluster="\
    http://ftp.gnu.org/gnu \
    http://www.gtlib.gatech.edu/pub/gnu/gnu \
    http://mirrors.kernel.org/gnu \
    http://ftp.funet.fi/pub/gnu/prep"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_GITHUB()
(
    # pattern [element]/%ACCOUNT%/%PROJECT%/tar.gz/%HASH|TAG%?dummy=/
    local SUBDIR="${1##GITHUB/}"
    case ${SUBDIR} in
        *:) return 1 ;;
    esac
    set -f
    IFS=:
    set -- ${SUBDIR}
    [ "$#" -eq 3 ] && [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] || return 1
    printf '%s\n' "https://codeload.github.com/${1}/${2}/tar.gz/${3}?dummy=/"
)

expand_GITHUB_PRIVATE()
(
    # Legacy syntax: account:project:ref:unused:token (fourth field may be empty).
    local SUBDIR="${1#*/}"
    case ${SUBDIR} in
        *:) return 1 ;;
    esac
    set -f
    IFS=:
    set -- ${SUBDIR}
    [ "$#" -eq 5 ] && [ -n "$1" ] && [ -n "$2" ] &&
        [ -n "$3" ] && [ -n "$5" ] || return 1
    printf '%s\n' "https://api.github.com/repos/${1}/${2}/tarball/${3}?access_token=${5}&dummy=/"
)

expand_GITLAB()
(
    # pattern [element]/api/v4/projects/%ACCOUNT%[%2F]%PROJECT%/repository/archive?sha=%HASH|TAG%&dummy=/
    local SUBDIR="${1##GITLAB/}"
    case ${SUBDIR} in
        *:) return 1 ;;
    esac
    set -f
    IFS=:
    set -- ${SUBDIR}
    [ "$#" -eq 3 ] && [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ] || return 1
    printf '%s\n' "https://gitlab.com/api/v4/projects/${1}%2F${2}/repository/archive?sha=${3}&dummy=/"
)

expand_OPENBSD()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##OPENBSD/}"
    local cluster="\
    https://ftp.OpenBSD.org/pub/OpenBSD/ \
    https://ftp.eu.openbsd.org/pub/OpenBSD/ \
    https://ftp3.usa.openbsd.org/pub/OpenBSD/ \
    https://mirror.aarnet.edu.au/pub/OpenBSD/"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_CPAN()
{
    # pattern [element]/modules/by-module/%SUBDIR%/
    local SUBDIR AUTHID site
    local _PERL_CPAN_SORT=modules/by-module
    SUBDIR=${1##CPAN/}
    AUTHID=${1##CPAN/ID:}
    local cluster="\
    http://cpan.metacpan.org \
    http://www.cpan.org \
    http://ftp.jaist.ac.jp/pub/CPAN \
    ftp://ftp.mirrorservice.org/sites/cpan.perl.org/CPAN \
    http://backpan.perl.org \
    ftp://ftp.funet.fi/pub/languages/perl/CPAN \
    http://ftp.twaren.net/Unix/Lang/CPAN"

    if [ "${AUTHID}" != "${1}" ]; then
	for site in ${cluster}; do
	    site_directory_url "${site}/modules/by-authors/id" "${AUTHID}"
	done
    else
	# Possible to-do: Implement alternative _PERL_CPAN_SORT=authors/id
	for site in ${cluster}; do
	    site_directory_url "${site}/${_PERL_CPAN_SORT}" "${SUBDIR}"
	done
    fi;
}

expand_SOURCEWARE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##SOURCEWARE/}"
    local cluster="\
    http://mirrors.kernel.org/sourceware \
    ftp://ftp.funet.fi/pub/mirrors/sourceware.org/pub"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_GCC()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##GCC/}"
    local cluster="\
        http://mirrors.kernel.org/sourceware/gcc \
        http://mirror.koddos.net/gcc \
        https://mirrorservice.org/sites/sourceware.org/pub/gcc \
        http://ftp-stud.hs-esslingen.de/pub/Mirrors/sourceware.org/gcc"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_PYPI()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##PYPI/}"
    local cluster="\
    https://files.pythonhosted.org/packages/source \
    https://pypi.python.org/packages/source"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_PYPIWHL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##PYPIWHL/}"
    local site="https://files.pythonhosted.org/packages"
    site_directory_url "${site}" "${SUBDIR}"
}

expand_FREELOCAL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##FREELOCAL/}"
    local cluster="\
    http://distcache.FreeBSD.org/local-distfiles \
    http://distcache.us-east.FreeBSD.org/local-distfiles \
    http://distcache.eu.FreeBSD.org/local-distfiles \
    http://distcache.us-west.FreeBSD.org/local-distfiles"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_LEAFDIST()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##LEAFDIST/}"
    local site="https://leaf.dragonflybsd.org/~marino/raven-distfiles"
    site_directory_url "${site}" "${SUBDIR}"
}


expand_ORPHANED()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##ORPHANED/}"
    local site="https://leaf.dragonflybsd.org/~marino/orphaned-distfiles"
    site_directory_url "${site}" "${SUBDIR}"
}


expand_GNUPG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##GNUPG/}"
    local cluster="\
    https://gnupg.org/ftp/gcrypt \
    http://mirrors.dotsrc.org/gcrypt \
    http://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_PGSQL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##PGSQL/}"
    local cluster="\
    http://ftp.postgresql.org/pub \
    https://ftp.postgresql.org/pub"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_MYSQL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##MYSQL/}"
    # Archive directories use a lowercase mysql- prefix.
    local ARCHIVE_SUBDIR="${SUBDIR}"
    case ${SUBDIR} in
        MySQL-*) ARCHIVE_SUBDIR=mysql-${SUBDIR#MySQL-} ;;
    esac
    site_directory_url "https://cdn.mysql.com/Downloads" "${SUBDIR}"
    site_directory_url "https://cdn.mysql.com/archives" "${ARCHIVE_SUBDIR}"
}

expand_MOZILLA()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##MOZILLA/}"
    local cluster="\
    https://download.cdn.mozilla.net/pub \
    https://archive.mozilla.org/pub"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_UBUNTU()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##UBUNTU/}"
    local cluster="\
    http://mirrors.kernel.org/ubuntu/pool/main \
    http://nl.archive.ubuntu.com/ubuntu/pool/main \
    http://de.archive.ubuntu.com/ubuntu/pool/main \
    http://mirrors.xmission.com/ubuntu/pool/main"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_XORG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##XORG/}"
    local cluster="\
    http://xorg.freedesktop.org/releases \
    http://mirror.csclub.uwaterloo.ca/x.org \
    http://mirrors.ircam.fr/pub/x.org \
    http://www.mirrorservice.org/sites/ftp.x.org/pub \
    http://ftp.yz.yamagata-u.ac.jp/pub/X11/x.org"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_GNOME()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##GNOME/}"
    local cluster="\
    https://download.gnome.org/sources \
    http://download.gnome.org/sources \
    http://fr2.rpmfind.net/linux/gnome.org/sources \
    http://www.gtlib.gatech.edu/pub/gnome/sources \
    http://ftp.gnome.org/pub/GNOME/sources"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_RUBY()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##RUBY/}"
    local cluster="\
    http://cache.ruby-lang.org/pub/ruby \
    http://ftp.ruby-lang.org/pub/ruby"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_RUBYGEMS()
{
    # pattern [element]/%SUBDIR%/
    # local SUBDIR=${1##RUBYGEMS/}
    local cluster="\
    https://rubygems.org/downloads"
    local site
    for site in ${cluster}; do
	printf '%s\n' "${site}/"
    done
}

expand_PHP()
{
    # pattern [element]/%SUBDIR%/
    # Mirror program discontinued 1 April 2019
    # https://github.com/php/web-php/commit/b2b48ca1e053eae9ed0ace036b69ff3ab6926869
    local SUBDIR="${1##PHP/}"
    local site="https://www.php.net"
    site_directory_url "${site}" "${SUBDIR}"
}

expand_TOR()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##TOR/}"
    local cluster="\
    https://www.torproject.org/dist \
    https://archive.torproject.org/tor-package-archive \
    http://cyberside.net.ee/tor"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_SAVANNAH()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##SAVANNAH/}"
    local site="https://download-mirror.savannah.gnu.org/releases"
    site_directory_url "${site}" "${SUBDIR}"
}

expand_ISC()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##ISC/}"
    local cluster="\
    http://ftp.isc.org/isc \
    ftp://ftp.isc.org/isc \
    ftp://ftp.iij.ad.jp/pub/network/isc \
    ftp://ftp.mirrorservice.org/sites/ftp.isc.org/isc \
    ftp://ftp.ripe.net/mirrors/sites/ftp.isc.org/isc \
    ftp://ftp.funet.fi/pub/mirrors/ftp.isc.org/isc"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_DEBIAN()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##DEBIAN/}"
    local cluster="\
    http://cdn.debian.net/debian \
    http://www.gtlib.gatech.edu/pub/debian \
    ftp://ftp.us.debian.org/debian \
    http://ftp.au.debian.org/debian \
    http://ftp.cl.debian.org/debian \
    ftp://ftp.cz.debian.org/debian \
    ftp://ftp.de.debian.org/debian \
    http://ftp.wa.au.debian.org/debian"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}

expand_CRATES()
(
    # pattern [element]/%PROJECT%/%VERSION%/download?dummy=/
    local SUBDIR="${1##CRATES/}"
    case ${SUBDIR} in
        *:) return 1 ;;
    esac
    set -f
    IFS=:
    set -- ${SUBDIR}
    [ "$#" -eq 2 ] && [ -n "$1" ] && [ -n "$2" ] || return 1
    printf '%s\n' "https://crates.io/api/v1/crates/${1}/${2}/download?dummy=/"
)

expand_GIMP()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##GIMP/}"
    local site="https://download.gimp.org/pub"
    site_directory_url "${site}" "${SUBDIR}"
}

expand_CRAN()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##CRAN/}"
    local cluster="\
    https://cloud.r-project.org \
    https://stat.ethz.ch/CRAN \
    https://cran.csiro.au \
    https://mirrors.tuna.tsinghua.edu.cn/CRAN \
    https://mirror.las.iastate.edu/CRAN \
    https://cran.ma.imperial.ac.uk"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}


expand_ADACORE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##ADACORE/}"
    local site="https://community.download.adacore.com/v1"
    site_directory_url "${site}" "${SUBDIR}"
}


expand_KERNEL_ORG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR="${1##KERNEL_ORG/}"
    local cluster="\
    https://cdn.kernel.org/pub \
    https://www.kernel.org/pub \
    https://mirrors.mit.edu/kernel \
    http://ftp.nara.wide.ad.jp/pub/kernel.org \
    http://ftp.yandex.ru/pub \
    ftp://ftp.ntu.edu.tw"
    local site
    for site in ${cluster}; do
	site_directory_url "${site}" "${SUBDIR}"
    done
}


process_site()
{
    case "${1}" in
	ADACORE/*)                 expand_ADACORE "${1}" ;;
	APACHE/*)                  expand_APACHE "${1}" ;;
	APACHE_COMMONS_BINARIES/*) expand_APACHE_COMMONS_BINARIES "${1}" ;;
	APACHE_COMMONS_SOURCE/*)   expand_APACHE_COMMONS_SOURCE "${1}" ;;
	APACHE_HTTPD/*)            expand_APACHE_HTTPD "${1}" ;;
	APACHE_JAKARTA/*)          expand_APACHE_JAKARTA "${1}" ;;
	CPAN/*)                    expand_CPAN "${1}" ;;
	CRAN/*)                    expand_CRAN "${1}" ;;
	CRATES/*)                  expand_CRATES "${1}" ;;
	DEBIAN/*)                  expand_DEBIAN "${1}" ;;
	FREELOCAL/*)               expand_FREELOCAL "${1}" ;;
	GCC/*)                     expand_GCC "${1}" ;;
	GITHUB/*)                  expand_GITHUB "${1}" ;;
	GIMP/*)                    expand_GIMP "${1}" ;;
	GITHUB_PRIVATE/*|GHPRIV/*) expand_GITHUB_PRIVATE "${1}" ;;
	GITLAB/*)                  expand_GITLAB "${1}" ;;
	GNOME/*)                   expand_GNOME "${1}" ;;
	GNU/*)                     expand_GNU "${1}" ;;
	GNUPG/*)                   expand_GNUPG "${1}" ;;
	ISC/*)                     expand_ISC "${1}" ;;
	KERNEL_ORG/*)              expand_KERNEL_ORG "${1}" ;;
	LEAFDIST/*)                expand_LEAFDIST "${1}" ;;
	MOZILLA/*)                 expand_MOZILLA "${1}" ;;
	MYSQL/*)                   expand_MYSQL "${1}" ;;
	OPENBSD/*)                 expand_OPENBSD "${1}" ;;
	ORPHANED/*)                expand_ORPHANED "${1}" ;;
	PGSQL/*)                   expand_PGSQL "${1}" ;;
	PHP/*)                     expand_PHP "${1}" ;;
	PYPI/*)			   expand_PYPI "${1}" ;;
	PYPIWHL/*)		   expand_PYPIWHL "${1}" ;;
	RUBY/*)			   expand_RUBY "${1}" ;;
	RUBYGEMS/*)                expand_RUBYGEMS "${1}" ;;
	SAVANNAH/*)                expand_SAVANNAH "${1}" ;;
	SOURCEFORGE/*)             expand_SOURCEFORGE "${1}" 1 ;;
	SF/*)                      expand_SOURCEFORGE "${1}" 2 ;;
	SOURCEWARE/*)              expand_SOURCEWARE "${1}" ;;
	TOR/*)                     expand_TOR "${1}" ;;
	UBUNTU/*)                  expand_UBUNTU "${1}" ;;
	XORG/*)                    expand_XORG "${1}" ;;
	*)                         printf '%s\n' "$@" ;;
    esac
}

#example DL_SITE:
#process_site "APACHE/incubator/log4net/1.2.10"
