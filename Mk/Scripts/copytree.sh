#!/bin/sh
#
# Implement COPYTREE_SHARE and COPYTREE_BIN in an actual shell script
# Reason for moving out of Makefile: gfind doesn't like the passing of $2
#   even after rearranging command order.
# Yes, this function expects GNU find, not BSD find.
#
# Argument 1:  New file mode (distinguishes _SHARE and BIN)
# Argument 2:  search patch for find
# Argument 3:  destination directory to copy the tree
# Argument 4:  Optional: find command modifiers, e.g. "-not -name 'Makefile*'"

if [ $# -lt 3 ]; then
   echo "At least 3 arguments expected";
   exit 1;
fi

FILE_MODE=$1
SEARCH_PATH=$2
DESTINO=$3
if [ $# -ge 4 ]; then
   FIND_MODIFIERS=$4
else
   FIND_MODIFIERS=
fi

manifests=$(eval find ${SEARCH_PATH} -depth ${FIND_MODIFIERS})
[ $? -eq 0 ] || (echo "failed manifest step" && exit 1)

# copy the tree with cpio
# -d : Create directories as necessary.
# -u : Unconditionally overwrite existing files.
# -m : Preserve modification time
# -p : Pass-through (read list of file names from standard input)
# -l : Create links from target directory to original files instead of copying.

echo ${manifests} | awk '{ for (x=1;x<=NF;x++) print $x}' | cpio -pmudl ${DESTINO} > /dev/null 2>&1
[ $? -eq 0 ] || (echo "failed cpio step $?"  && exit 1)

# Get list of new directories
target_dirs=$(find ${DESTINO} -depth -type d)
[ $? -eq 0 ] || (echo "failed target_dirs step" && exit 1)

# Change file mode of directories to 755 
chmod 755 ${target_dirs}
[ $? -eq 0 ] || (echo "failed to change directory modes" && exit 1)

# Get list of new files
target_files=$(find ${DESTINO}/${SEARCH_PATH} -depth -type f)
[ $? -eq 0 ] || (echo "failed target_files step" && exit 1)

echo ${target_files} | xargs chmod ${FILE_MODE}
[ $? -eq 0 ] || (echo "failed to change file modes" && exit 1)
