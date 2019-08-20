#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - LIBDRM_TAG
# - MESA_BRANCH

main() {
    # Clone sources.
    git clone https://salsa.debian.org/xorg-team/lib/libdrm &&
        (cd libdrm &&
         git checkout -B debian-unstable "${LIBDRM_TAG}")

    git clone https://chromium.googlesource.com/chromiumos/third_party/mesa &&
        (cd mesa &&
         git checkout -B "${MESA_BRANCH}" origin/"${MESA_BRANCH}")
}

main "$@"
