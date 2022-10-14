#!/bin/bash
# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -eux

main() {
    local dist="$1"
    local arch="$2"
    local buildresult="$3"

    tgzfile="/var/cache/pbuilder/debian-${dist}-${arch}.tgz"
    if [ ! -f "${tgzfile}" ]; then
        # Create the pbuilder chroot. .pbuilderrc uses ARCH, DIST and DEPSBASE.
        DIST="${dist}" ARCH="${arch}" DEPSBASE="${buildresult}" \
            pbuilder create \
            --distribution "${dist}" \
            --architecture "${arch}"
    fi
}

main "$@"
