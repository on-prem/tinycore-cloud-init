#!/bin/sh
#
# Tasks for mounting persistent storage (AoE)
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

logfile="/var/log/storage.log"
datamount="/data"

################

get_aoe_device() {
  aoe_device=$(get_storagedata "device" || get_userdata "aoe_device" || get_vendordata "aoe_device")
}

write_storage_settings() {
  cat > /usr/local/etc/storage.conf <<EOF
type=aoe
device=$aoe_device
EOF
}

find_aoe_disks() {
  modprobe aoe
  sleep 2
  echo > /dev/etherd/discover
}

get_fs_type() {
  fstype=$(blkid -o value -s TYPE "/dev/etherd/${aoe_device}")
}

check_mounted_drive() {
  [ ! -n "$(mount | grep "on $datamount")" ]
}

mount_data_disk() {
  echo_val $aoe_device

  mount -v -t $fstype "/dev/etherd/${aoe_device}" $datamount >> $logfile 2>&1
}

fix_datamount_permissions() {
  chown 1001:997 $datamount
  chmod 0775 $datamount
}

trap fail_and_exit EXIT

echo_msg "Mounting AoE storage"

get_aoe_device
write_storage_settings
find_aoe_disks
get_fs_type
check_mounted_drive
mount_data_disk
fix_datamount_permissions

echo_done

exit 0
