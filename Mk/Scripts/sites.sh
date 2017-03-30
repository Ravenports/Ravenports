#!/bin/sh

set -e

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_DO_FETCH}" ] && set -x
set -u

# Global (used in more than one expansion)
apache_cluster="\
  	http://www.apache.org/dist \
	http://archive.apache.org/dist \
	http://ftp.twaren.net/Unix/Web/apache \
	http://apache.mirror.uber.com.au \
	http://apache.spd.co.il \
	http://ftp.mirrorservice.org/sites/ftp.apache.org \
	http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist \
	ftp://mir1.ovh.net/ftp.apache.org/dist \
	ftp://ftp.forthnet.gr/pub/www/apache \
	ftp://xenia.sote.hu/pub/mirrors/www.apache.org \
	ftp://ftp.heanet.ie/mirrors/www.apache.org/dist \
	ftp://ftp.sunet.se/pub/www/servers/apache/dist \
	http://mirrors.ircam.fr/pub/apache"

# keep in order

expand_APACHE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##APACHE/}
    for site in ${apache_cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_APACHE_COMMONS_BINARIES()
{
    # pattern [element]/commons/%SUBDIR%/binaries/
    # note: differs from FreeBSD ports
    local SUBDIR=${1##APACHE_COMMONS_BINARIES/}
    for site in ${apache_cluster}; do
	echo ${site}/commons/${SUBDIR}/binaries/
    done
}

expand_APACHE_COMMONS_SOURCE()
{
    # pattern [element]/commons/%SUBDIR%/source/
    # note: differs from FreeBSD ports
    local SUBDIR=${1##APACHE_COMMONS_SOURCE/}
    for site in ${apache_cluster}; do
	echo ${site}/commons/${SUBDIR}/source/
    done
}

expand_APACHE_HTTPD()
{
    # pattern [element]/httpd/%SUBDIR%/
    local SUBDIR=${1##APACHE_HTTPD/}
    for site in ${apache_cluster}; do
	echo ${site}/httpd/${SUBDIR}/
    done
}

expand_APACHE_JAKARTA()
{
    # pattern [element]/jakarta/%SUBDIR%/
    local SUBDIR=${1##APACHE_JAKARTA/}
    for site in ${apache_cluster}; do
	echo ${site}/jakarta/${SUBDIR}/
    done
}

expand_SOURCEFORGE()
{
    # pattern [element]/%SUBDIR%/
    # note: differs from FreeBSD ports
    local SUBDIR;
    if [ ${2} -eq 1 ]; then
	SUBDIR=${1##SOURCEFORGE/}
    else
    	SUBDIR=${1##SF/}
    fi
    local cluster="\
    http://heanet.dl.sourceforge.net/project \
    http://iweb.dl.sourceforge.net/project \
    http://freefr.dl.sourceforge.net/project \
    http://jaist.dl.sourceforge.net/project \
    http://master.dl.sourceforge.net/project \
    http://nchc.dl.sourceforge.net/project \
    http://ncu.dl.sourceforge.net/project \
    http://internode.dl.sourceforge.net/project \
    http://waix.dl.sourceforge.net/project \
    http://superb-dca3.dl.sourceforge.net/project \
    http://ufpr.dl.sourceforge.net/project \
    http://tenet.dl.sourceforge.net/project \
    http://netcologne.dl.sourceforge.net/project \
    http://ignum.dl.sourceforge.net/project \
    http://downloads.dl.sourceforge.net/project \
    http://kent.dl.sourceforge.net/project"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_GNU()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##GNU/}
    local cluster="\
    http://ftpmirror.gnu.org \
    http://ftp.gnu.org/gnu \
    ftp://ftp.gnu.org/gnu \
    http://www.gtlib.gatech.edu/pub/gnu/gnu \
    http://mirrors.kernel.org/gnu \
    ftp://ftp.kddlabs.co.jp/GNU/gnu \
    ftp://ftp.dti.ad.jp/pub/GNU \
    ftp://ftp.mirrorservice.org/sites/ftp.gnu.org/gnu \
    ftp://ftp.informatik.hu-berlin.de/pub/gnu/gnu \
    ftp://ftp.informatik.rwth-aachen.de/pub/mirror/ftp.gnu.org/pub/gnu \
    http://ftp.funet.fi/pub/gnu/prep"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_GITHUB()
{
    # pattern [element]/%ACCOUNT%/%PROJECT%/tar.gz/%HASH/TAG%?dummy=/
    local SUBDIR
    if [ ${2} -eq 1 ]; then
	SUBDIR=${1##GITHUB/}
    else
	SUBDIR=${1##GH/}
    fi
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://codeload.github.com/${1}/${2}/tar.gz/${3}?dummy=/"
}

expand_GITHUB_CLOUD()
{
    # pattern [element]/%ACCOUNT%/%PROJECT%/
    local SUBDIR
    if [ ${2} -eq 1 ]; then
	SUBDIR=${1##GITHUB_CLOUD/}
    else
	SUBDIR=${1##GHC/}
    fi
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://cloud.github.com/downloads/${1}/${2}/"
}

expand_OPENBSD()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##OPENBSD/}
    local cluster="\
    https://ftp.OpenBSD.org/pub/OpenBSD/ \
    https://ftp.eu.openbsd.org/pub/OpenBSD/ \
    https://ftp3.usa.openbsd.org/pub/OpenBSD/ \
    https://openbsd.hk/pub/OpenBSD/ \
    https://mirror.aarnet.edu.au/pub/OpenBSD/ \
    https://mirrors.evowise.com/pub/OpenBSD/"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

process_site()
{
    case "${1}" in
	APACHE/*)                  expand_APACHE "${1}" ;;
	APACHE_COMMONS_BINARIES/*) expand_APACHE_COMMONS_BINARIES "${1}" ;;
	APACHE_COMMONS_SOURCE/*)   expand_APACHE_COMMONS_SOURCE "${1}" ;;
	APACHE_HTTPD/*)            expand_APACHE_HTTPD "${1}" ;;
	APACHE_JAKARTA/*)          expand_APACHE_JAKARTA "${1}" ;;
	GITHUB/*)                  expand_GITHUB "${1}" 1 ;;
	GH/*)                      expand_GITHUB "${1}" 2 ;;
	GITHUB_CLOUD/*)            expand_GITHUB_CLOUD "${1}" 1 ;;
	GHC/*)                     expand_GITHUB_CLOUD "${1}" 2 ;;
	GNU/*)                     expand_GNU "${1}" ;;
	OPENBSD/*)                 expand_OPENBSD "${1}" ;;
	SOURCEFORGE/*)             expand_SOURCEFORGE "${1}" 1 ;;
	SF/*)                      expand_SOURCEFORGE "${1}" 2 ;;
	*)                         echo "${1}" ;;
    esac
}

#example DL_SITE:
#process_site "APACHE/incubator/log4net/1.2.10"
