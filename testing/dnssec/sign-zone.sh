#!/bin/sh

if test $# -eq 0 ; then
    echo "Usage: $0 <zone-file>" 1>&2
    exit 0
fi

dsset=$(dirname $0)/dsset
keys=$(dirname $0)/keys

zonefile=$1
zonedir=$(dirname ${zonefile})
zone=$(basename ${zonefile})

# increment the zone's serial
serial=$(cat ${zonedir}/serial)
serial=$(expr ${serial} + 1)
echo ${serial} > ${zonedir}/serial
sed -i -e "/[Ss]erial/ s/[0-9][0-9]*/${serial}/" ${zonefile}

dnssec-signzone -q -d ${dsset} -g -S -K ${keys} -x -f ${zonefile}.signed -o ${zone} ${zonefile}
