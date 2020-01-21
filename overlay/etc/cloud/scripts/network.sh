#!/bin/sh
#
# Tasks for configuring network settings
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

get_network_config() {
  [ -f /etc/sysconfig/network-config ]
}

configure_network_settings() {
  cloud-init devel net-convert -p /etc/sysconfig/network-config -d / -D ubuntu -O eni -k yaml
}

get_eni_config() {
  [ -f /etc/network/interfaces.d/50-cloud-init.cfg ]
}

apply_network_settings() {
  ifdown -a
  ifconfig eth0 up
  ifup -a
}

trap fail_and_exit EXIT

echo_msg "Saving settings"
echo_opt "network"

  get_network_config && \
  configure_network_settings || true

echo_done

echo_msg "Applying settings"
echo_opt "network"

  get_eni_config
  apply_network_settings

echo_done

exit 0
