#!/bin/sh
/sbin/modprobe ipv6
/usr/local/bin/cloud-init init --local
/usr/local/bin/cloud-init init >/dev/null 2>&1
/opt/network.sh
/opt/bootsetup.sh
/opt/bootlocal.sh
