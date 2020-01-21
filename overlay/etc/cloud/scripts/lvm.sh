#!/bin/sh
#
# Tasks for configuring LVM disks
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

extend="no"
logfile="/var/log/lvm.log"
all_disks="b c d e f g h i j k l m n o p" # max 15 disks
vgname="data"
lvname="disk2"
disk2="/dev/${vgname}/${lvname}"
mountpoint="/data"
lvusage="95%VG" # use 95% of the volume group's disk space

################

read_storagetype() {
  storagetype=$(cat /etc/sysconfig/storagetype)
}

create_lvm_disk() {
  if [ "$storagetype" = "local" ]; then
    echo_msg "Preparing LVM disks"
    IFS=' '
    for i in $all_disks; do
      diskname="/dev/sd${i}"
      check_disk_block $diskname && \
      check_disk_pv $diskname && \
      check_disk_lv $diskname && \
      create_pv $diskname && \
      echo_val "sd${i}" && \
      create_extend_disk $diskname
    done
    echo_done
  fi
  true
}

check_disk_block() {
  [ -b $1 ]
}

check_disk_pv() {
  [ -z "$(pvdisplay -c $1 2>/dev/null)" ]
}

check_disk_lv() {
  [ ! "$(blkid -o value -s TYPE $1)" = "LVM2_member" ]
}

create_pv() {
  pvcreate $1 >> $logfile 2>&1
}

create_extend_disk() {
  [ -z "$(vgdisplay -c $vgname)" ] && create_vg $1 || extend_vg $1
}

create_vg() {
  vgcreate $vgname $$1 >> $logfile 2>&1
  lvcreate -l $lvusage -n $lvname $vgname
  mkfs.xfs -L "${vgname}-${lvname}" -f $disk2 >> $logfile 2>&1
}

extend_vg() {
  vgextend $vgname $1 >> $logfile 2>&1
  extend="yes"
}

resize_lvm_disk() {
  if [ "$extend" = "yes" ] && [ "$storagetype" = "local" ]; then
    extend_lv
    resize_fs
  fi
}

extend_lv() {
  lvextend -l $lvusage $disk2 >> $logfile 2>&1
  vgchange -ay >> $logfile 2>&1
  sleep 2
}

resize_fs() {
  fstype=$(blkid -o value -s TYPE $disk2)
  if [ "$fstype" = "xfs" ]; then
    resize_xfs
  elif [ "$fstype" = "ext4" ]; then
    resize_ext4
  else
    echo "Unable to resize disk $disk2, unknown filesystem: $fstype" >> $logfile
    return 1
  fi
}

resize_xfs() {
  mount -v -t xfs -L "${vgname}-${lvname}" $mountpoint >> $logfile 2>&1
  xfs_growfs $disk2 >> $logfile 2>&1
  umount $disk2
}

resize_ext4() {
  e2fsck -f -y $disk2 >> $logfile 2>&1
  resize2fs $disk2 >> $logfile 2>&1
}

trap fail_and_exit EXIT

read_storagetype
create_lvm_disk
resize_lvm_disk

exit 0
