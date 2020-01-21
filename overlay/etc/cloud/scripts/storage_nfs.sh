#!/bin/sh
#
# Tasks for mounting persistent storage (NFS)
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

get_nfs_ip() {
  nfs_ip=$(get_storagedata "ip" || get_userdata "nfs_ip" || get_vendordata "nfs_ip")
}

get_nfs_share() {
  nfs_share=$(get_storagedata "share" || get_userdata "nfs_share" || get_vendordata "nfs_share")
}

get_nfs_mount_options() {
  nfs_mount_options=$(get_storagedata "mount_options" || get_userdata "nfs_mount_options" || get_vendordata "nfs_mount_options")
}

write_storage_settings() {
  cat > /usr/local/etc/storage.conf <<EOF
type=nfs
ip=$nfs_ip
share=$nfs_share
mount_options=$nfs_mount_options"
EOF
}

start_nfs_client() {
  /usr/local/etc/init.d/nfs-client start >/var/log/service-nfs-client.log 2>&1 &
  sleep 2
}

check_mounted_drive() {
  [ ! -n "$(mount | grep "on $datamount")" ]
}

mount_nfs_disk() {
  echo_val "${nfs_ip}:${nfs_share}"

  mount -v -t nfs -o "nfsvers=3,${nfs_mount_options}" "${nfs_ip}:${nfs_share}" $datamount >> $logfile 2>&1
}

trap fail_and_exit EXIT

echo_msg "Mounting NFS storage"

get_nfs_ip
get_nfs_share
get_nfs_mount_options
write_storage_settings
start_nfs_client
check_mounted_drive
mount_nfs_disk

echo_done

exit 0
