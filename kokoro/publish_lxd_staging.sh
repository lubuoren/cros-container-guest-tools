#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

. "common.sh" || exit 1

main() {
    if [ -z "${KOKORO_ARTIFACTS_DIR}" ]; then
        echo "This script must be run in kokoro"
        exit 1
    fi

    if [ -z "${CROS_MILESTONE}" ]; then
        echo "CROS_MILESTONE must be set"
        exit 1
    fi

    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/lxd
    if [ "${CROS_MILESTONE}" -ge 70 ]; then
        result_dir="${result_dir}/${CROS_MILESTONE}"
    fi
    mkdir -p "${result_dir}"

    # TODO(smbarber): create simplestreams index/images.
}

main "$@"
