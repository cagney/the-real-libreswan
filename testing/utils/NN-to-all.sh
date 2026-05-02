#!/bin/sh

set -eu

NNTOALL() {
    local h=$1
    local f=$2
    if test -r "$f" ; then
	echo "# ${h} $(basename ${f})"
	echo
	sed -e "s/^/${h}# /" ${f}
	echo
    fi
}

# old-old style

for s in init run ; do
    for h in nic east west north road ; do
	NNTOALL "${h}" "${1}/${h}${s}.sh"
    done
done

for f in $1/[0-9]*.sh ; do
    # what about 01-north-road.sh?
    for t in $(basename $f .sh | tr '[-]' '[ ]') ; do
	h=$(case $t in
		*nic*) echo nic ;;
		*east*) echo east ;;
		*west* ) echo west ;;
		*rise* ) echo rise ;;
		*set*) echo set ;;
		*road* ) echo road ;;
		*north* ) echo north ;;
	    esac)
	if test -n "${h}" ; then
	    NNTOALL ${h} $f
	fi
    done
done

NNTOALL final $1/final.sh
