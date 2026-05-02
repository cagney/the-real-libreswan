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

