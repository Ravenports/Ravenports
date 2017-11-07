#!/bin/sh
#
# The purpose of this script is to regenerate patches.
# The following is maintained:
#   1. The original name of the patch file
#   2. First comment (lines between top of file and first "--- " line)
#   3. Multiple patches in a single patch file
#
# The original patches are expected to be at /port/patches.
# The regenerated patches are placed at /tmp/shiny/
# The ravenadm tool is responsible for replacing the port's
# patches and "extra" patches (this script can't know which patches in
# /ports/patches came from "extra" patches originally)
#
# This script takes two arguments:
#   mandatory : $1 WRKSRC directory
#   mandatory : $2 strip components (0,1,2,..,9)
# This script is not meant to be run by users;
# It is a helper script for ravenadm.
#
# Note: It is run *after* patches have already been applied, so the script
#       assumes that the application was successful (no rejected hunks)
# Note: requires genpatch version 1.60 or later

if [ $# -lt 2 ]; then
   echo "usage: repatch.sh <wrksrc path> <strip number>"
   exit 0;
fi

WRKSRC=$1
STRIPCOMP=$2

if [ ! -d ${WRKSRC} ]; then
   echo "repatch.sh error, not a directory: ${WRKSRC}"
   exit 0;
fi

case ${STRIPCOMP} in
   [0-9]) ;;
   *)     echo "repatch.sh error, not integer 0-9: ${STRIPCOMP}"
          exit 0;
esac

AWK=/usr/bin/awk
rm -rf /tmp/shiny
/bin/mkdir -p /tmp/shiny

PATCHLIST=
if [ -d /port/patches ]; then
   PATCHLIST=/port/patches/patch-*
fi
if [ -d /port/opsys ]; then
   OSP=/port/opsys/patch-*
   PATCHLIST="${PATCHLIST} ${OSP}"
fi
for PFILE in ${PATCHLIST}; do
   ENTRIES=$(${AWK} '/--- / { pn++; print pn }' ${PFILE})
   BNAMEX=$(/usr/bin/basename ${PFILE})
   BNAME=${BNAMEX##patch-zzz-}
   TARGET=/tmp/shiny/${BNAME}
   ${AWK} '/--- / { exit 0 } { print }' ${PFILE} > ${TARGET}
   for entry in ${ENTRIES}; do
      PPATH=$(${AWK} -vsc=${STRIPCOMP} -vpatch=${entry} '/\+\+\+ / {\
 pn++;\
 if (pn == patch)\
 {\
  if (sc == 0)\
  {\
    if (substr($2, 1, 2) == "b/")\
      { print substr($2, 3) }\
    else\
      { print $2 }\
  }\
  else\
  {\
    nc = split ($2, comp, "/");\
    for (x = sc + 1; x < nc; x++) { printf ("%s/", comp[x]) };\
    printf ("%s", comp[nc]);\
  }\
  exit 0;
 }\
}\
{ next }' ${PFILE})
      echo "patching ${PPATH} >> ${TARGET}"
      (cd ${WRKSRC} && /usr/bin/env PRINT=1 /usr/bin/genpatch ${PPATH}) >> ${TARGET}
   done
done
