#!/bin/sh
#
# $1: prefix
# $2: opsys
# $3: arch
# $4: standardized arch
# $5: OS kernel version
# $6: OS release
# $7: OS Major version
#
# Returns 0 if all the arguments match the installed bmake

bmake=$1/bin/bmake
uname=$1/bin/ravensys-uname
/usr/bin/touch /tmp/blankmake
answer1=$($bmake -f /tmp/blankmake -V .MAKE.OS.NAME)
answer2=$($bmake -f /tmp/blankmake -V .MAKE.OS.ARCHITECTURE)
answer3=$($bmake -f /tmp/blankmake -V .MAKE.OS.ARCH.STANDARD)
answer4=$($bmake -f /tmp/blankmake -V .MAKE.OS.VERSION)
answer5=$($bmake -f /tmp/blankmake -V .MAKE.OS.RELEASE)
answer6=$($bmake -f /tmp/blankmake -V .MAKE.OS.MAJOR)
uname1=$($uname -s)
uname2=$($uname -m)
uname3=$($uname -U)
uname4=$($uname -r)
all="$answer1/$answer2/$answer3/$answer4/$answer5/$answer6"
all2="$uname1/$uname2/$uname3/$uname4"
errmsg="bmake verification test failed, contains $all"
recmsg="Rebuild bmake package and retry.";
errmsg2="uname verification test failed, contains $all2"
recmsg2="Rebuild ravensys-uname package and retry.";

if [ "$2" != "$answer1" ]; then
	echo "$errmsg (.MAKE.OS.NAME)"
	echo $recmsg
	exit 1
fi
if [ "$3" != "$answer2" ]; then
	echo "$errmsg (.MAKE.OS.ARCHITECTURE)"
	echo $recmsg
	exit 1
fi
if [ "$4" != "$answer3" ]; then
	echo "$errmsg (.MAKE.OS.ARCH.STANDARD)"
	echo $recmsg
	exit 1
fi
if [ "$5" != "$answer4" ]; then
	echo "$errmsg (.MAKE.OS.VERSION)"
	echo $recmsg
	exit 1
fi
if [ "$6" != "$answer5" ]; then
	echo "$errmsg (.MAKE.OS.RELEASE)"
	echo $recmsg
	exit 1
fi
if [ "$7" != "$answer6" ]; then
	echo "$errmsg (.MAKE.OS.MAJOR)"
	echo $recmsg
	exit 1
fi
echo "bmake verification test passed"

# now check ravensys-uname
if [ "$2" != "$uname1" ]; then
	echo "$errmsg2 (OS.NAME)"
	echo $recmsg2
	exit 1
fi
if [ "$3" != "$uname2" ]; then
	echo "$errmsg2 (OS.MACHINE)"
	echo $recmsg2
	exit 1
fi
if [ "$5" != "$uname3" ]; then
	echo "$errmsg2 (OS.KERNEL)"
	echo $recmsg2
	exit 1
fi
# don't check release -- not all end in -RAVEN
# if [ "$6-RAVEN" != "$uname4" ]; then
#	echo "$errmsg2 (OS.RELEASE)"
#	echo $recmsg2
#	exit 1
# fi
echo "ravensys-uname verification test passed"
