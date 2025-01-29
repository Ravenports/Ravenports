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
    http://freefr.dl.sourceforge.net/project \
    http://jaist.dl.sourceforge.net/project \
    http://netcologne.dl.sourceforge.net/project \
    http://netix.dl.sourceforge.net/project \
    http://ufpr.dl.sourceforge.net/project \
    http://excellmedia.dl.sourceforge.net/project \
    http://nchc.dl.sourceforge.net/project"
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
    # pattern [element]/%ACCOUNT%/%PROJECT%/tar.gz/%HASH|TAG%?dummy=/
    local SUBDIR=${1##GITHUB/}
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://codeload.github.com/${1}/${2}/tar.gz/${3}?dummy=/"
}

expand_GITLAB()
{
    # pattern [element]/api/v4/projects/%ACCOUNT%[%2F]%PROJECT%/repository/archive?sha=%HASH|TAG%&dummy=/
    local SUBDIR=${1##GITLAB/}
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://gitlab.com/api/v4/projects/${1}%2F${2}/repository/archive?sha=${3}&dummy=/"
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

expand_GITHUB_PRIVATE()
{
    # Google takes security access token and generates a new TOKEN
    # and redirects to codeload server, losing any extraneous GET variables
    # pattern [element]/%ACCOUNT%/%PROJECT%/tarball/%HASH%?access_token=%TOKEN%&dummy=/
    local SUBDIR
    if [ ${2} -eq 1 ]; then
	SUBDIR=${1##GITHUB_PRIVATE/}
    else
	SUBDIR=${1##GHPRIV/}
    fi
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://api.github.com/repos/${1}/${2}/tarball/${3}?access_token=${5}&dummy=/"
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

expand_CPAN()
{
    # pattern [element]/modules/by-module/%SUBDIR%/
    local SUBDIR AUTHID
    local _PERL_CPAN_SORT=modules/by-module
    SUBDIR=${1##CPAN/}
    AUTHID=${1##CPAN/ID:}
    local cluster="\
    http://cpan.metacpan.org \
    http://www.cpan.org \
    ftp://ftp.cpan.org/pub/CPAN \
    http://www.cpan.dk \
    ftp://ftp.kddlabs.co.jp/lang/perl/CPAN \
    http://ftp.jaist.ac.jp/pub/CPAN \
    ftp://ftp.sunet.se/pub/lang/perl/CPAN \
    ftp://ftp.mirrorservice.org/sites/cpan.perl.org/CPAN \
    ftp://ftp.auckland.ac.nz/pub/perl/CPAN \
    http://backpan.perl.org \
    ftp://ftp.funet.fi/pub/languages/perl/CPAN \
    http://ftp.twaren.net/Unix/Lang/CPAN \
    ftp://ftp.cpan.org"

    if [ "${AUTHID}" != "${1}" ]; then
	for site in ${cluster}; do
	    echo ${site}/modules/by-authors/id/${AUTHID}/
	done
    else
	# Possible to-do: Implement alternative _PERL_CPAN_SORT=authors/id
	for site in ${cluster}; do
	    echo ${site}/${_PERL_CPAN_SORT}/${SUBDIR}/
	done
    fi;
}

expand_SOURCEWARE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##SOURCEWARE/}
    local cluster="\
    http://mirrors.kernel.org/sourceware \
    http://gd.tuwien.ac.at/gnu/sourceware \
    ftp://ftp.funet.fi/pub/mirrors/sourceware.org/pub"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_GCC()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##GCC/}
    local cluster="\
        http://mirrors.kernel.org/sourceware/gcc \
        http://mirror.koddos.net/gcc \
        https://ftp.nluug.nl/languages/gcc \
        https://mirrorservice.org/sites/sourceware.org/pub/gcc \
        https://bigsearcher.com/mirrors/gcc \
	http://gcc.cybermirror.org \
	http://robotlab.itk.ppke.hu/gcc \
	http://ftp-stud.hs-esslingen.de/pub/Mirrors/sourceware.org/gcc \
	http://mirrors.concertpass.com/gcc"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_PYPI()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##PYPI/}
    local cluster="\
    https://files.pythonhosted.org/packages/source \
    https://pypi.python.org/packages/source"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_PYPIWHL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##PYPIWHL/}
    local cluster="https://files.pythonhosted.org/packages"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_FREELOCAL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##FREELOCAL/}
    local cluster="\
    http://distcache.FreeBSD.org/local-distfiles \
    http://distcache.us-east.FreeBSD.org/local-distfiles \
    http://distcache.eu.FreeBSD.org/local-distfiles \
    http://distcache.us-west.FreeBSD.org/local-distfiles"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_GNUPG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##GNUPG/}
    local cluster="\
    https://gnupg.org/ftp/gcrypt \
    http://ftp.heanet.ie/mirrors/ftp.gnupg.org/gcrypt \
    ftp://ftp.sunet.se/pub/security/gnupg \
    ftp://ftp.franken.de/pub/crypt/mirror/ftp.gnupg.org/gcrypt \
    ftp://mirror.switch.ch/mirror/gnupg \
    http://gd.tuwien.ac.at/privacy/gnupg \
    http://mirrors.dotsrc.org/gcrypt \
    ftp://ftp.crysys.hu/pub/gnupg \
    http://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt \
    http://artfiles.org/gnupg.org \
    ftp://ftp.gnupg.org/gcrypt \
    http://mirror.tje.me.uk/pub/mirrors/ftp.gnupg.org"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_PGSQL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##PGSQL/}
    local cluster="\
    http://ftp.postgresql.org/pub \
    https://ftp.postgresql.org/pub \
    ftp://ftp.postgresql.org/pub"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_MYSQL()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##MYSQL/}
    local cluster="\
    https://cdn.mysql.com/Downloads \
    https://cdn.mysql.com/archives"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_MOZILLA()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##MOZILLA/}
    local cluster="\
    https://download.cdn.mozilla.net/pub \
    https://archive.mozilla.org/pub"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_UBUNTU()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##UBUNTU/}
    local cluster="\
    http://mirrors.kernel.org/ubuntu/pool/main \
    http://nl.archive.ubuntu.com/ubuntu/pool/main \
    http://ubuntu.mirrors.tds.net/ubuntu/pool/main \
    http://de.archive.ubuntu.com/ubuntu/pool/main \
    http://mirrors.xmission.com/ubuntu/pool/main"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_XORG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##XORG/}
    local cluster="\
    http://xorg.freedesktop.org/releases \
    http://xorg.mirrors.pair.com \
    http://mirror.us.leaseweb.net/xorg \
    http://mirror.csclub.uwaterloo.ca/x.org \
    http://artfiles.org/x.org/pub \
    http://ftp.gwdg.de/pub/x11/x.org/pub \
    http://mi.mirror.garr.it/mirrors/x.org \
    http://mirror.switch.ch/ftp/mirror/X11/pub \
    http://mirrors.ircam.fr/pub/x.org \
    http://www.mirrorservice.org/sites/ftp.x.org/pub \
    http://www.portal-to-web.de/pub/mirrors/x.org \
    http://xorg.mirror.solnet.ch/pub \
    http://gd.tuwien.ac.at/X11 \
    http://ftp.yz.yamagata-u.ac.jp/pub/X11/x.org \
    http://ftp.kaist.ac.kr/x.org"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_GNOME()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##GNOME/}
    local cluster="\
    https://download.gnome.org/sources \
    http://download.gnome.org/sources \
    http://fr2.rpmfind.net/linux/gnome.org/sources \
    http://www.gtlib.gatech.edu/pub/gnome/sources \
    http://ftp.gnome.org/pub/GNOME/sources"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_RUBY()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##RUBY/}
    local cluster="\
    http://cache.ruby-lang.org/pub/ruby \
    http://ftp.ruby-lang.org/pub/ruby \
    ftp://ftp.ruby-lang.org/pub/ruby \
    ftp://ftp.fu-berlin.de/unix/languages/ruby \
    ftp://ftp.kr.FreeBSD.org/pub/ruby \
    ftp://ftp.iDaemons.org/pub/mirror/ftp.ruby-lang.org/ruby"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_RUBYGEMS()
{
    # pattern [element]/%SUBDIR%/
    # local SUBDIR=${1##RUBYGEMS/}
    local cluster="\
    https://rubygems.org/downloads \
    https://rubygems.global.ssl.fastly.net/gems"
    for site in ${cluster}; do
	echo ${site}/
    done
}

expand_PHP()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##PHP/}
    local cluster="\
    http://us2.php.net \
    http://de.php.net \
    http://es.php.net \
    http://fr.php.net \
    http://it.php.net \
    http://jp.php.net \
    http://se.php.net \
    http://uk3.php.net \
    http://br.php.net \
    http://cn.php.net"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_TOR()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##TOR/}
    local cluster="\
    https://www.torproject.org/dist \
    https://archive.torproject.org/tor-package-archive \
    ftp://ftp.bit.nl/mirror/tor \
    http://cyberside.net.ee/tor \
    http://ftp.bit.nl/mirror/tor \
    http://mirror.hessmo.com/tor/dist \
    http://mirror.host4site.co.il/torproject.org/dist \
    http://mirror.open-networx.org/torproject.org/dist \
    http://mirror.tor.hu/dist \
    https://mirror.torland.me/torproject.org/dist \
    http://mirrors.chaos-darmstadt.de/tor-mirror/dist \
    http://theonionrouter.com/dist \
    https://www.coevoet.nl/tor/dist \
    http://www.oignon.net/dist \
    http://www.torproject.nl/dist \
    http://www.torproject.org.nyud.net/dist \
    http://www.torproject.us/dist \
    http://www.torservers.net/mirrors/torproject.org/dist"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_SAVANNAH()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##SAVANNAH/}
    local cluster="\
    http://download.savannah.gnu.org/releases \
    http://download-mirror.savannah.gnu.org/releases \
    http://nongnu.askapache.com \
    http://mirror.lihnidos.org/GNU/savannah \
    http://ftp.twaren.net/Unix/NonGNU \
    ftp://ftp.twaren.net/Unix/NonGNU \
    http://gnu.mirrors.pair.com/savannah/savannah \
    ftp://gnu.mirrors.pair.com/savannah"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_ISC()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##ISC/}
    local cluster="\
    http://ftp.isc.org/isc \
    ftp://ftp.isc.org/isc \
    ftp://ftp.ciril.fr/pub/isc \
    ftp://ftp.iij.ad.jp/pub/network/isc \
    ftp://ftp.dti.ad.jp/pub/net/isc \
    ftp://ftp.u-aizu.ac.jp/pub/net/isc \
    ftp://ftp.task.gda.pl/mirror/ftp.isc.org/isc \
    ftp://ftp.sunet.se/pub/network/isc \
    ftp://ftp.mirrorservice.org/sites/ftp.isc.org/isc \
    ftp://ftp.nominum.com/pub/isc \
    ftp://ftp.ripe.net/mirrors/sites/ftp.isc.org/isc \
    ftp://ftp.ntua.gr/pub/net/isc/isc \
    ftp://ftp.funet.fi/pub/mirrors/ftp.isc.org/isc"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_DEBIAN()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##DEBIAN/}
    local cluster="\
    http://cdn.debian.net/debian \
    http://www.gtlib.gatech.edu/pub/debian \
    ftp://ftp.us.debian.org/debian \
    http://ftp.au.debian.org/debian \
    http://ftp.cl.debian.org/debian \
    ftp://ftp.cz.debian.org/debian \
    ftp://ftp.de.debian.org/debian \
    http://ftp.wa.au.debian.org/debian"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_CRATES()
{
    # pattern [element]/%PROJECT%/%VERSION%/download?dummy=/
    local SUBDIR=${1##CRATES/}
    OLD_IFS=${IFS}
    IFS=:
    set -- ${SUBDIR}
    IFS=${OLD_IFS}
    echo "https://crates.io/api/v1/crates/${1}/${2}/download?dummy=/"
}

expand_GIMP()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##GIMP/}
    local cluster="\
    https://download.gimp.org/pub"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}

expand_CRAN()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##CRAN/}
    local cluster="\
    https://cloud.r-project.org \
    https://stat.ethz.ch/CRAN \
    http://cran.utstat.utoronto.ca \
    https://cran.cnr.berkeley.edu \
    https://cran.csiro.au \
    https://mirrors.tuna.tsinghua.edu.cn/CRAN \
    http://camoruco.ing.uc.edu.ve/cran \
    https://mirror.las.iastate.edu/CRAN \
    https://cran.ma.imperial.ac.uk \
    https://cran.gis-lab.info \
    https://cran.ism.ac.jp"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}


expand_ADACORE()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##ADACORE/}
    local cluster="https://community.download.adacore.com/v1"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
    done
}


expand_KERNEL_ORG()
{
    # pattern [element]/%SUBDIR%/
    local SUBDIR=${1##KERNEL_ORG/}
    local cluster="\
    https://cdn.kernel.org/pub \
    https://www.kernel.org/pub \
    https://download.xs4all.nl/ftp.kernel.org/pub \
    https://mirrors.mit.edu/kernel \
    http://ftp.nara.wide.ad.jp/pub/kernel.org \
    http://ftp.yandex.ru/pub \
    http://ftp.heanet.ie/pub/kernel.org/pub \
    ftp://ftp.ntu.edu.tw \
    ftp://ftp.riken.jp/Linux/kernel.org"
    for site in ${cluster}; do
	echo ${site}/${SUBDIR}/
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
	GITHUB_CLOUD/*)            expand_GITHUB_CLOUD "${1}" 1 ;;
	GHC/*)                     expand_GITHUB_CLOUD "${1}" 2 ;;
	GIMP/*)                    expand_GIMP "${1}" ;;
	GITHUB_PRIVATE/*)          expand_GITHUB_PRIVATE "${1}" 1 ;;
	GITLAB/*)                  expand_GITLAB "${1}" ;;
	GHPRIV/*)                  expand_GITHUB_PRIVATE "${1}" 2 ;;
	GNOME/*)                   expand_GNOME "${1}" ;;
	GNU/*)                     expand_GNU "${1}" ;;
	GNUPG/*)                   expand_GNUPG "${1}" ;;
	ISC/*)                     expand_ISC "${1}" ;;
	KERNEL_ORG/*)              expand_KERNEL_ORG "${1}" ;;
	MOZILLA/*)                 expand_MOZILLA "${1}" ;;
	MYSQL/*)                   expand_MYSQL "${1}" ;;
	OPENBSD/*)                 expand_OPENBSD "${1}" ;;
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
	*)                         echo $@ ;;
    esac
}

#example DL_SITE:
#process_site "APACHE/incubator/log4net/1.2.10"
