#!/bin/sh
#
# Tasks for configuring hostname
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

read_hostname() {
  hostname=$(cat /etc/hostname)
}

write_hosts_file() {
  sed -i "/^127.0.1.1/c\127.0.1.1 $hostname" /etc/hosts
}

set_hostname() {
  echo_val "$hostname"

  hostname "$hostname"
}

trap fail_and_exit EXIT

echo_msg "Setting hostname to"

read_hostname
write_hosts_file
set_hostname

echo_done

exit 0
