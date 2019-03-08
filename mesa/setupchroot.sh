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
    for arch in ${ARCHES[@]}; do
        # Only create the chroot once.
        if [ ! -d "/var/cache/pbuilder/base-${DISTRIBUTION}-${arch}.cow" ]; then
            # Create the pbuilder chroot.
            DIST="${DISTRIBUTION}" ARCH="${arch}" git-pbuilder create \
                --mirror http://deb.debian.org/debian \
                --debootstrapopts \
                    --keyring="/usr/share/keyrings/debian-archive-keyring.gpg" \
                --keyring="${HOME}/llvm-keyring.gpg"
        fi
    done
}

main "$@"
