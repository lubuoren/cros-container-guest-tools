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
# - MESA_BRANCH

main() {
    # Packages stored here will be accessible outside of the build as well
    # as used for buildpackages of subsequent packages (via hooks).
    export GIT_PBUILDER_OUTPUT_DIR="${ARTIFACTS}"

    for arch in ${ARCHES[@]}; do
        # Build libdrm.
        (cd libdrm &&
            DIST="${DISTRIBUTION}" ARCH="${arch}" gbp buildpackage \
                --git-debian-branch=debian-unstable \
                --git-upstream-tree=origin/upstream-unstable)

        # Build mesa.
        (cd mesa &&
            DIST="${DISTRIBUTION}" ARCH="${arch}" gbp buildpackage \
                --git-debian-branch="${MESA_BRANCH}" \
                --git-upstream-tree=origin/master)
    done
}

main "$@"
