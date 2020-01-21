#!/bin/sh
#
# Tasks which should only run once
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

hostname_file="/etc/hostname"
ntpserver_file="/etc/sysconfig/ntpserver"
storagetype_file="/etc/sysconfig/storagetype"
iptables_file="/usr/local/etc/iptables"
ip6tables_file="/usr/local/etc/ip6tables"

get_hostname() {
  hostname=$(cat $hostname_file || get_userdata "hostname" || get_vendordata "hostname")
}

write_hostname_file() {
  echo "$hostname" > $hostname_file
}

write_hosts_file() {
  cat > /etc/hosts <<EOF
127.0.1.1 localhost
127.0.0.1 localhost localhost.local

# The following lines are desirable for IPv6 capable hosts
# (added automatically by netbase upgrade)

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF
}

get_ntp() {
  ntpserver=$(cat $ntpserver_file || get_userdata "ntpserver" || get_vendordata "ntpserver")
}

write_ntpserver_file() {
  echo "$ntpserver" > $ntpserver_file
}

get_storage() {
  storagetype=$(cat $storagetype_file || get_userdata "storagetype" || get_vendordata "storagetype")
}

write_storagetype_file() {
  echo "$storagetype" > $storagetype_file
}

update_firewall() {
  [ -f "$iptables_file" ] && /usr/local/sbin/iptables-restore --verbose < $iptables_file >>/var/log/firewall.log 2>&1
  [ -f "$ip6tables_file" ] && /usr/local/sbin/ip6tables-restore --verbose < $ip6tables_file >>/var/log/firewall.log 2>&1
}

trap fail_and_exit EXIT

echo_msg "Saving settings"
echo_opt "hostname, ntpserver, firewall"

get_hostname
write_hostname_file
write_hosts_file
get_ntp
write_ntpserver_file
get_storage
write_storagetype_file
update_firewall

echo_done

exit 0
