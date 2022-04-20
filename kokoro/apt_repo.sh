#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

. "$(dirname "$0")/common.sh" || exit 1

main() {
    require_kokoro_artifacts
    stop_apt_daily

    sudo apt-get -q update
    sudo apt-get -q -y install reprepro

    local src_root="${KOKORO_ARTIFACTS_DIR}/git/cros-container-guest-tools"
    local repo_dir="${src_root}"/apt_unsigned
    mkdir -p "${repo_dir}"/{,conf}

    # We keep deprecated versions here indefinitely so "apt update" will pull
    # down an empty repo instead of getting a hard 404 error.
    for release in stretch buster bullseye; do
        local distributions="
Origin: Google
Label: cros-containers
Suite: stable
Codename: ${release}
Version: 1.0
Architectures: amd64 arm64 armhf i386
Components: main
Description: CrOS containers guest tools
"

        echo "${distributions}" >> "${repo_dir}/conf/distributions"

        local deb_dirs=("${release}-debs" "${release}_mesa_debs")

        local deb
        for subdir in "${deb_dirs[@]}"; do
            local debdir="${KOKORO_GFILE_DIR}"/"${subdir}"
            if [ -d "${debdir}" ]; then
                for deb in "${debdir}"/*.deb; do
                    reprepro -b "${repo_dir}" includedeb "${release}" "${deb}"
                done
            fi
        done
    done

    # Ensure Release files for all versions are generated, even if we ship no
    # packages for them.
    reprepro -b "${repo_dir}" export
}

main "$@"
