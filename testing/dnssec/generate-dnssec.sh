#!/bin/sh

set -e

DIR=$(realpath $(dirname $0))
cd $DIR

# Initialize scratch directories, seed with README files

rm -rf ${DIR}/*/
for d in keys zones dsset ; do
    mkdir -p $d
    cp README.$d $d/README
done

# Zone serial number (shared across all zones)
#
# Everytime a zone is signed, first increment the global serial, and
# then update the SERIAL record.

echo 1 > zones/serial

zones="192.in-addr.arpa libreswan.org"

# Generate keys for all zones and subzones.
#
# Every time the zone is signed, the same keys are used.  Hence keygen
# needs to happen only once.  The DS (Delegation Signer) record is
# generated from the key signing key and hence, it too only needs to
# be generated once.

generate_keys() {
    zsk=$(dnssec-keygen -K keys -b 1024        -a RSASHA256 -n ZONE $1)
    ksk=$(dnssec-keygen -K keys -b 2048 -f KSK -a RSASHA256 -n ZONE $1)
    dnssec-dsfromkey keys/$ksk | tee dsset/dsset-$1.
}

for zone in ${zones} ; do
    generate_keys $zone
    for subzone in *.${zone} ; do
	generate_keys $subzone
    done
done

cat dsset/dsset-* >> dsset/dsset.all
cat keys/*key > keys/testing.key

# Sign the zones
#
# The zone files need to include the subzone DS (Delegation Signer) records
# generated above.

for zone in ${zones} ; do
    cp ${zone} zones/${zone}
    for subzone in *.${zone} ; do
	cat dsset/dsset-${subzone}. >> zones/${zone}
    done
    ./sign-zone.sh zones/$zone
done

# Sign the subzones.
#
# Everytime a subzone is updated, its serial needs to be incremented,
# and then resigned using the keys above.  Use the pre-existing DS
# (Delegation Signer) generated above.

for zone in ${zones} ; do
    for subzone in *.${zone} ; do
	cp ${subzone} zones/${subzone}
	./sign-zone.sh zones/${subzone}
    done
done

# to test
# dig +sigchase +trusted-key=/testing/baseconfigs/all/etc/bind/dsset/dsset.all  east.testing.libreswan.org
