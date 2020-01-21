#!/bin/sh
#
# Custom tasks (once)
#
# MIT Licensed
#
# Copyright (c) 2020 Alexander Williams, Unscramble <license@unscramble.jp>
#
# VERSION: 1.0.0

set -u
set -e

. /etc/cloud/scripts/functions.sh

trap fail_and_exit EXIT

exit 0
