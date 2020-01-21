#!/bin/sh
#
# Tasks for configuring resolv.conf
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

check_networking_dhcp() {
  grep -q "iface eth0 inet dhcp$" /etc/network/interfaces.d/50-cloud-init.cfg
}

get_dns_search_address() {
  nameservers_search=$(grep "dns-search" /etc/network/interfaces.d/50-cloud-init.cfg | awk '{ print $2 }')
  [ -n "$nameservers_search" ] && ns_search="search $nameservers_search" || ns_search=""
}

get_dns_domain_address() {
  nameservers_domain=$(grep "dns-domain" /etc/network/interfaces.d/50-cloud-init.cfg | awk '{ print $2 }')
  [ -n "$nameservers_domain" ] && ns_domain="domain $nameservers_domain" || ns_domain=""
}

get_dns_nameserver_address() {
  nameservers_dns=$(grep "dns-nameservers" /etc/network/interfaces.d/50-cloud-init.cfg | awk '{ print $2; if ($3 != "") print $3; }')
  echo_val "$nameservers_dns"

  IFS='
'
  ns_dns=""
  for x in $nameservers_dns; do
    if [ -n "$ns_dns" ]; then
      ns_dns="${ns_dns}
nameserver $x"
    else
      ns_dns="nameserver $x"
    fi
  done
}

write_resolv_conf() {
  cat > /etc/resolv.conf <<EOF
$ns_dns
$ns_search
$ns_domain
EOF
}

trap fail_and_exit EXIT

if ! check_networking_dhcp; then
  echo_msg "Setting DNS servers to"

  get_dns_search_address
  get_dns_domain_address
  get_dns_nameserver_address
  write_resolv_conf

  echo_done
fi

exit 0
