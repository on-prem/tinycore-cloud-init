#!/bin/sh
#
# Tasks for mounting persistent storage (local)
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
vgname="data"
lvname="disk2"
disk2="/dev/${vgname}/${lvname}"

################

activate_local_disk() {
  vgchange -ay >> $logfile 2>&1
  sleep 2
}

get_fs_type() {
  fstype=$(blkid -o value -s TYPE $disk2)
}

write_storage_settings() {
  cat > /usr/local/etc/storage.conf <<EOF
type=local
EOF
}

check_mounted_drive() {
  [ ! -n "$(mount | grep "on $datamount")" ]
}

mount_data_disk() {
  echo_val $disk2

  mount -v -t $fstype $disk2 $datamount >> $logfile 2>&1
}

fix_datamount_permissions() {
  chown 1001:997 $datamount
  chmod 0775 $datamount
}

trap fail_and_exit EXIT

echo_msg "Mounting local storage"

activate_local_disk
get_fs_type
write_storage_settings
check_mounted_drive
mount_data_disk
fix_datamount_permissions

echo_done

exit 0
