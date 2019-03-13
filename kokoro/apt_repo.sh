#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

main() {
    if [ -z "${KOKORO_ARTIFACTS_DIR}" ]; then
        echo "This script must be run in kokoro"
        exit 1
    fi

    local src_root="${KOKORO_ARTIFACTS_DIR}/git/cros-container-guest-tools"
    local repo_dir="${src_root}"/apt_unsigned
    mkdir -p "${repo_dir}"/{,conf}

    for release in stretch buster; do
        local distributions="
Origin: Google
Label: cros-containers
Codename: ${release}
Version: 1.0
Architectures: amd64 arm64 armhf i386
Components: main
Description: CrOS containers guest tools
"

        echo "${distributions}" >> "${repo_dir}/conf/distributions"

        local deb
        for subdir in guest_debs mesa_debs; do
            local debdir="${KOKORO_GFILE_DIR}"/"${subdir}"
            if [ -d "${debdir}" ]; then
                for deb in "${debdir}"/*.deb; do
                    reprepro -b "${repo_dir}" includedeb "${release}" "${deb}"
                done
            fi
        done
    done
}

main "$@"
