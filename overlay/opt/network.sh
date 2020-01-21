#!/bin/sh
#
# TinyCore static/dhcp networking (cloud-init)
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>

set -u
set -e

/usr/local/bin/cloud-init modules --mode config
