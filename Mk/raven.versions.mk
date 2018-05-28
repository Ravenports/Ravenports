# Provide default versions for ports with multiple versions selectable
# by the user.
#
# Users who want to override these defaults can easily do so by defining
# DEFAULT_VERSIONS in their make.conf as follows:
#
# DEFAULT_VERSIONS=	perl5=5.20 ruby=2.0
#

.if !defined(_INCLUDE_BSD_DEFAULT_VERSIONS_MK)
_INCLUDE_BSD_DEFAULT_VERSIONS_MK=	yes

.  for base in FIREBIRD LUA MYSQL PERL5 PHP PGSQL PYTHON3 RUBY SSL TCL
.undef ${base}_DEFAULT
.  endfor

.  for base in ${DEFAULT_VERSIONS}
_l=			${base:C/=.*//g}
${_l:tu}_DEFAULT=	${base:C/.*=//g}
.  endfor

#-------------------------------------------------------------------------
# PERL5
# Possible values: 5.24, 5.26
#-------------------------------------------------------------------------

PERL5_DEFAULT?=		5.26

PERL_5.24_VERSION=	5.24.4
PERL_5.26_VERSION=	5.26.2

#-------------------------------------------------------------------------
# RUBY
# Possible values: 2.3, 2.4, 2.5
#-------------------------------------------------------------------------

RUBY_DEFAULT?=		2.4

RUBY_2.3_VERSION=	2.3.7
RUBY_2.4_VERSION=	2.4.4
RUBY_2.5_VERSION=	2.5.1

#-------------------------------------------------------------------------
# PYTHON
# Possible values: 2.7, 3.4, 3.5
#-------------------------------------------------------------------------

PYTHON3_DEFAULT?=	3.6

PYTHON_2.7_VERSION=	2.7.15
PYTHON_3.5_VERSION=	3.5.5
PYTHON_3.6_VERSION=	3.6.5

#-------------------------------------------------------------------------
# SSL
# Possible values: openssl, openssl-devel, libressl, libressl-devel
#-------------------------------------------------------------------------

SSL_DEFAULT?=		libressl

#-------------------------------------------------------------------------
# LUA
# Possible values: 5.2, 5.3
#-------------------------------------------------------------------------

LUA_DEFAULT?=		5.3

LUA_5.2_VERSION=	5.2.4
LUA_5.3_VERSION=	5.3.4

#-------------------------------------------------------------------------
# TCL/TK
# Possible values: 8.5, 8.6
#-------------------------------------------------------------------------

TCL_DEFAULT?=		8.6

TCL_8.5_VERSION=	8.5.19
TCL_8.6_VERSION=	8.6.8

#-------------------------------------------------------------------------
# PGSQL
# Possible values: 9.2, 9.3, 9.4, 9.5, 9.6, 10.0
#-------------------------------------------------------------------------

PGSQL_DEFAULT?=		9.6

PGSQL_9.3_VERSION=	9.3.23
PGSQL_9.4_VERSION=	9.4.18
PGSQL_9.5_VERSION=	9.5.13
PGSQL_9.6_VERSION=	9.6.9
PGSQL_10.0_VERSION=	10.4

#-------------------------------------------------------------------------
# MYSQL and derivatives
# Possible values: oracle-(5.5,5.6,5.7), mariadb-(10.1,10.2),
#                  percona-(5.5,5.6,5.7), galera-(5.5,5.6,5.7)
#-------------------------------------------------------------------------

MYSQL_DEFAULT=			oracle-5.7

MYSQL_oracle-5.7_VERSION=	5.7.22
MYSQL_oracle-5.6_VERSION=	5.6.40
MYSQL_oracle-5.5_VERSION=	5.5.60
MYSQL_mariadb-10.2_VERSION=	10.2.5
MYSQL_mariadb-10.1_VERSION=	10.1.22
MYSQL_percona-5.7_VERSION=	5.7.17
MYSQL_percona-5.6_VERSION=	5.6.35
MYSQL_percona-5.5_VERSION=	5.5.54
MYSQL_galera-5.7_VERSION=	5.7.17
MYSQL_galera-5.6_VERSION=	5.6.35
MYSQL_galera-5.5_VERSION=	5.5.54

#-------------------------------------------------------------------------
# Firebird database server
# Possible values: 2.5, 3.0
#-------------------------------------------------------------------------

FIREBIRD_DEFAULT?=	2.5

FIREBIRD_2.5_VERSION=	2.5.8
FIREBIRD_3.0_VERSION=	3.0.3

#-------------------------------------------------------------------------
# PHP (restricted to branches still receiving updates)
# Possible values: 5.6, 7.1, 7.2
#-------------------------------------------------------------------------

PHP_DEFAULT?=		5.6

PHP_5.6_VERSION=	5.6.36
PHP_7.1_VERSION=	7.1.18
PHP_7.2_VERSION=	7.2.6

.endif # defined (_INCLUDE_BSD_DEFAULT_VERSIONS_MK)
