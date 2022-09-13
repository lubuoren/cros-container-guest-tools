#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

. "$(dirname "$0")/common.sh" || exit 1

main() {
    require_kokoro_artifacts
    require_cros_milestone

    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/apt
    if [ "${CROS_MILESTONE}" != "69" ]; then
        result_dir="${result_dir}/${CROS_MILESTONE}"
    fi
    mkdir -p "${result_dir}"

    cp -r "${KOKORO_GFILE_DIR}"/apt_signed/* "${result_dir}"
}

main "$@"
