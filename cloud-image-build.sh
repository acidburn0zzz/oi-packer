#!/bin/bash

#
# Produce a raw disk image that does not include the metadata agent and has a
# blank root password for console login.  Will output an uncompressed raw disk
# image at, e.g.,
#
#     /rpool/images/output/noconfig-ttya-openindiana-hipster.raw
#
# This tool requires "setup.sh" and "strap_oi.sh" to have been run first.
#

set -o xtrace
set -o pipefail
set -o errexit

TOP=$(cd "$(dirname "$0")" && pwd)
. "$TOP/lib/common.sh"

DISTRO=${DISTRO:-openindiana}
BRANCH=${BRANCH:-hipster}
CONSOLE=${CONSOLE:-ttya}

TOP=$(cd "$(dirname "$0")" && pwd)

cd "$TOP"

pfexec "image-builder" \
    build \
    -T "$TOP/templates" \
    -d "$DATASET" \
    -g cloudimage \
    -n "$CONSOLE-$DISTRO-$BRANCH"

ls -lh "$MOUNTPOINT/output/cloudimage-$CONSOLE-$DISTRO-$BRANCH.raw"
