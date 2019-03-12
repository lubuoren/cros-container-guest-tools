#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

main() {
    if [ -z "${KOKORO_ARTIFACTS_DIR}" ]; then
        echo "This script must be run in kokoro"
        exit 1
    fi

    local base_image="buildmesa"
    local base_image_tarball="${KOKORO_GFILE_DIR}"/"${base_image}".tar.xz

    if [[ "$(docker images -q ${base_image} 2> /dev/null)" == "" ]]; then
        docker load -i "${base_image_tarball}"
    fi

    docker run \
        --rm \
        --privileged \
        -v "${KOKORO_ARTIFACTS_DIR}"/mesa_debs:/artifacts \
        "${base_image}" \
        ./sync-and-build.sh
}

main "$@"
