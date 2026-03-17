east# /testing/guestbin/prep.sh
east# ../../guestbin/mount-bind.sh /etc/hosts /etc/hosts
east# echo "192.1.2.23 right.libreswan.org" >> /etc/hosts
east# ipsec start
east# ../../guestbin/wait-until-pluto-started
east# ipsec add named

set# /testing/guestbin/prep.sh
set# ../../guestbin/mount-bind.sh /etc/hosts /etc/hosts
set# echo "192.0.1.15 right.libreswan.org" >> /etc/hosts
set# ipsec start
set# ../../guestbin/wait-until-pluto-started
set# ipsec add named

west# /testing/guestbin/prep.sh
west# ../../guestbin/mount-bind.sh /etc/hosts /etc/hosts
west# echo "192.1.2.23 right.libreswan.org" >> /etc/hosts
west# ipsec start
west# ../../guestbin/wait-until-pluto-started

# bring up west

west# ipsec add named
west# ipsec up named

# redirect DNS

west# cp /etc/hosts /tmp/west.hosts
west# sed -e '/right.libreswan.org/ s/.*/192.0.1.0 right.libreswan.org/' /tmp/west.hosts > /etc/hosts

# kill existing
east# ipsec stop

# wait for revival to east; and then a swithc to DNS
west# ../../guestbin/wait-for-pluto.sh --match '"named" #2: connection is supposed to remain up'
west# ../../guestbin/wait-for-pluto.sh --match '"named" #3: initiating IKEv2 connection'
west# ../../guestbin/wait-for-pluto.sh --match '"named" #3: scheduling DDNS lookup'
west# ../../guestbin/wait-for-pluto.sh --match '"named" #3: deleting IKE SA'

# HACK to let existing SA shutdown; need to force DDNS so that DNS is
# rebuilt?

west# sleep 5
west# ipsec whack --ddns
