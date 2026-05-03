# nic nicinit.sh

nic# /testing/guestbin/nic-dnssec.sh start

# east eastinit.sh

east# /testing/guestbin/prep.sh
east# ipsec start
east# ../../guestbin/wait-until-pluto-started
east# ipsec auto --add named
east# echo "initdone"

# west westinit.sh

west# /testing/guestbin/prep.sh
west# ipsec start
west# ../../guestbin/wait-until-pluto-started

# since named has auto=up it will try to initiate (but DNS will fail)

west# ../../guestbin/wait-for-pluto.sh --match '"named": oriented'
west# ../../guestbin/wait-for-pluto.sh --match '"named": cannot initiate'
west# ipsec connectionstatus named | grep ===

# add missing DNS record

nic# echo right.testing.libreswan.org. IN A 192.1.2.23 >> /etc/nsd/zones/testing.libreswan.org
nic# /testing/dnssec/sign-zone.sh /etc/nsd/zones/testing.libreswan.org
nic# /testing/guestbin/nsd.sh reload
nic# /testing/guestbin/unbound.sh reload

# trigger DDNS event (saves us from waiting)

west# ipsec whack --ddns --name named
west# ../../guestbin/wait-for-pluto.sh --match '"named" #1: initiator established IKE SA'
west# ../../guestbin/wait-for-pluto.sh --match '"named" #2: initiator established Child SA'

# final final.sh

final# ipsec trafficstatus
