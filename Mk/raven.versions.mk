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

.  for base in PERL5 RUBY
.undef ${base}_DEFAULT
.  endfor

.  for base in ${DEFAULT_VERSIONS}
_l=			${base:C/=.*//g}
${_l:tu}_DEFAULT=	${base:C/.*=//g}
.  endfor

#-------------------------------------
# PERL5
# Possible values: 5.22, 5.24
#-------------------------------------

PERL5_DEFAULT?=		5.24

PERL_5.22_VERSION=      5.22.3
PERL_5.24_VERSION=	5.24.1

#-------------------------------------
# RUBY
# Possible values: 2.2, 2.3, 2.4
#-------------------------------------

RUBY_DEFAULT?=		2.4

.endif # defined (_INCLUDE_BSD_DEFAULT_VERSIONS_MK)
