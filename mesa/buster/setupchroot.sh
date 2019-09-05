#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - ARCHES
# - DISTRIBUTION

main() {
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true
    if [ -f /proc/sys/fs/binfmt_misc/aarch64 ]; then
       echo "binfmt aarch64 already registered"
    else
        local header=':aarch64:M::'
        local magic='\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00'
        magic+='\x00\x00\x00\x00\x02\x00\xb7\x00:'
        local mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff'
        mask+='\xff\xff\xff\xff\xfe\xff\xff\xff:'
        local interpreter='/usr/bin/qemu-aarch64-static:'
        echo $header$magic$mask$interpreter > /proc/sys/fs/binfmt_misc/register
    fi
    if [ -f /proc/sys/fs/binfmt_misc/arm ]; then
       echo "binfmt arm already registered"
    else
        local header=':arm:M::'
        local magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00'
        magic+='\x00\x00\x00\x00\x02\x00\x28\x00:'
        local mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff'
        mask+='\xff\xff\xff\xff\xfe\xff\xff\xff:'
        local interpreter='/usr/bin/qemu-arm-static:'
        echo $header$magic$mask$interpreter > /proc/sys/fs/binfmt_misc/register
    fi

    # Create chroots for each architecture.
    for arch in ${ARCHES[@]}; do
        tgzfile="/var/cache/pbuilder/base-${arch}.tgz"
        if [ ! -f "${tgzfile}" ]; then
            # Create the pbuilder chroot. .pbuilderrc uses ARCH and DIST.
            DIST="${CHROOT_DISTRIBUTION}"\
            ARCH="${arch}" \
            pbuilder create \
                --mirror http://deb.debian.org/debian \
                --distribution "${CHROOT_DISTRIBUTION}" \
                --architecture "${arch}" \
                --debootstrapopts \
                    --keyring="/usr/share/keyrings/debian-archive-keyring.gpg"
        fi
    done

    # pbuilder in the chroot defaults to pbuilder-satisfydepends which doesn't
    # work for us. We put the command into the global override config.
    SATISFY_DEPENDS="/usr/lib/pbuilder/pbuilder-satisfydepends-apt"
    echo PBUILDERSATISFYDEPENDSCMD="${SATISFY_DEPENDS}" \
        >> /etc/pbuilderrc
}

main "$@"
