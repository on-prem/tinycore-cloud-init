#!/bin/sh
#
# Tasks for configuring NTP
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

read_ntpserver() {
  ntpserver=$(cat /etc/sysconfig/ntpserver)
}

update_date() {
  /usr/sbin/ntpd -d -n -q -p $ntpserver >>/var/log/ntp.log 2>&1
}

trap fail_and_exit EXIT

echo_msg "Setting NTP date from"

read_ntpserver
echo_val "$ntpserver"
update_date || update_date || update_date

echo_done

exit 0
