#!/bin/sh
#
# Tasks for mounting persistent storage
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

cd /etc/cloud/scripts/
. ./functions.sh

logfile="/var/log/storage.log"
datamount="/data"

################

check_mounted_drive() {
  [ -n "$(mount | grep "on $1")" ]
}

mount_boot_drive() {
  echo_val "/dev/sda1"

  mount -v -t ext2 /dev/sda1 /mnt/sda1 >> $logfile 2>&1
}

read_storagetype() {
  storagetype=$(cat /etc/sysconfig/storagetype)
}

trap fail_and_exit EXIT

echo_msg "Mounting boot drive"

check_mounted_drive "/mnt/sda1" || mount_boot_drive
read_storagetype

echo_done

case "$storagetype" in
    "aoe") ./storage_aoe.sh;;
    "nfs") ./storage_nfs.sh;;
  "local") ./storage_local.sh;;
  *) exit 1
esac

exit 0
