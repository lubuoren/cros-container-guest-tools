#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - MESA_BUILD_BRANCH
# - MESA_CHECKOUT_BRANCH

main() {
    if [[ ! -d mesa ]]; then
        # Clone sources.
        git clone \
            https://chromium.googlesource.com/chromiumos/third_party/mesa &&
            (cd mesa &&
             git checkout origin/"${MESA_CHECKOUT_BRANCH}")
    fi

    cd mesa
    git checkout -B "${MESA_BUILD_BRANCH}"
}

main "$@"
