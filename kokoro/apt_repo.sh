#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

. "$(dirname "$0")/common.sh" || exit 1

main() {
    print_instance_details
    require_kokoro_artifacts
    stop_apt_daily

    sudo apt-get -q update
    sudo apt-get -q -y install reprepro

    local src_root="${KOKORO_ARTIFACTS_DIR}/git/cros-container-guest-tools"
    local repo_dir="${src_root}"/apt_unsigned
    mkdir -p "${repo_dir}"/{,conf}

    # We keep deprecated versions here indefinitely so "apt update" will pull
    # down an empty repo instead of getting a hard 404 error.
    for release in stretch buster bullseye bookworm; do
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

        local deb_dirs=("${release}-debs" \
            "${release}_mesa_debs" \
            "${release}_cros_im_debs")

        for subdir in "${deb_dirs[@]}"; do
            local debdir="${KOKORO_GFILE_DIR}"/"${subdir}"
            if [ -d "${debdir}" ]; then
                pushd "${debdir}" > /dev/null
                # Note: the maximum total length of command line arguments is
                # in practice limited to 1/4 the stack size, which is typically
                # 8 MiB. The names of all the debs should be well under this
                # size.
                reprepro -b "${repo_dir}" includedeb "${release}" ./*.deb
                popd > /dev/null
            fi
        done
    done

    # Ensure Release files for all versions are generated, even if we ship no
    # packages for them.
    reprepro -b "${repo_dir}" export
}

main "$@"
