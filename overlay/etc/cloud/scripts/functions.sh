#!/bin/sh

# ANSI COLORS
CRE="$(echo -e '\r\033[K')"
RED="$(echo -e '\033[1;31m')"
GREEN="$(echo -e '\033[1;32m')"
YELLOW="$(echo -e '\033[1;33m')"
BLUE="$(echo -e '\033[1;34m')"
MAGENTA="$(echo -e '\033[1;35m')"
CYAN="$(echo -e '\033[1;36m')"
WHITE="$(echo -e '\033[1;37m')"
NORMAL="$(echo -e '\033[0;39m')"

echo_msg() {
  echo -n "${BLUE}${1}...${NORMAL}"
}

echo_opt() {
  echo -n " ${YELLOW}${1}${NORMAL}"
}

echo_val() {
  echo -n " ${MAGENTA}${1}${NORMAL}"
}

echo_done() {
  echo "${GREEN} Done.${NORMAL}"
}

echo_fail() {
  echo "${RED} Failed.${NORMAL}"
}

fail_and_exit() {
  if [ "$?" -ne 0 ]; then
    echo_fail
  fi
}

get_storagedata() {
  data=$(grep "^${1}=" /usr/local/etc/storage.conf | awk -F '=' '{ print $2 }' | tr -d ' ')
  [ -n "$data" ] && echo $data || return 1
}

get_userdata() {
  data=$(grep "^${1}:" /var/lib/cloud/instance/user-data.txt | awk -F ':' '{ print $2 }' | tr -d ' ')
  [ -n "$data" ] && echo $data || return 1
}

get_vendordata() {
  data=$(grep "^${1}:" /var/lib/cloud/seed/nocloud-net/vendor-data | awk -F ':' '{ print $2 }' | tr -d ' ')
  [ -n "$data" ] && echo $data || return 1
}
