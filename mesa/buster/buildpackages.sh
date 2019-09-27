#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - ARCHES
# - ARTIFACTS
# - DISTRIBUTION
# - MESA_BUILD_BRANCH

main() {
    # Packages stored here will be accessible outside of the build as well
    # as used for buildpackages of subsequent packages (via hooks).
    for dist in ${DISTRIBUTIONS[@]}; do
        for arch in ${ARCHES[@]}; do
            mkdir -p "${ARTIFACTS}"
            (cd mesa &&
                DIST="${dist}" ARCH="${arch}" \
                pdebuild --debbuildopts "-i -d" \
                --buildresult "${ARTIFACTS}" \
                -- \
                --distribution "${dist}" \
                --architecture "${arch}" \
                --basetgz "/var/cache/pbuilder/base-${arch}.tgz")

        done
    done
}

main "$@"
