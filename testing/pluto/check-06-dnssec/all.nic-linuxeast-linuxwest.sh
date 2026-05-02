# nic nicinit.sh

nic# iptables -t nat -F
nic# iptables -F
nic# /bin/time -o OUTPUT/$(hostname).time /testing/guestbin/nic-dnssec.sh start
nic# echo done

# east eastinit.sh

east# /testing/guestbin/swan-prep
east# dig west.testing.libreswan.org
east# echo "initdone"

# west westinit.sh

west# /testing/guestbin/swan-prep
west# echo "initdone"

# west westrun.sh

west# ../../guestbin/wait-until-alive 192.1.2.254
west# dig east.testing.libreswan.org
west# dig +short east.testing.libreswan.org IPSECKEY | sort
west# dig +short @192.1.2.254 east.testing.libreswan.org
west# dig +short @192.1.2.254 chaos version.server txt
west# dig +short @192.1.2.254 -p 5353 east.testing.libreswan.org
west# dig +short @192.1.2.254 -p 5353 chaos version.server txt
west# echo done

# now add some new records

nic# echo 'right.testing.libreswan.org. IN A 192.1.2.23' >> /etc/nsd/zones/testing.libreswan.org # east
nic# tail -1 /etc/nsd/zones/testing.libreswan.org
nic# /testing/dnssec/sign-zone.sh /etc/nsd/zones/testing.libreswan.org
nic# /testing/guestbin/nsd.sh reload
nic# /testing/guestbin/unbound.sh reload

west# dig +short @192.1.2.254 -p 5353 right.testing.libreswan.org # NSD
west# dig +short @192.1.2.254         right.testing.libreswan.org # UNBOUND

# never cross the stream!

nic# sed -i -e '/right.testing.libreswan.org/ s/23/45/' /etc/nsd/zones/testing.libreswan.org # east->west
nic# tail -1 /etc/nsd/zones/testing.libreswan.org
nic# /testing/dnssec/sign-zone.sh /etc/nsd/zones/testing.libreswan.org
nic# /testing/guestbin/nsd.sh reload
nic# /testing/guestbin/unbound.sh reload

west# dig +short @192.1.2.254 -p 5353 right.testing.libreswan.org # NSD
west# dig +short @192.1.2.254         right.testing.libreswan.org # UNBOUND
