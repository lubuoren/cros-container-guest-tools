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
    local repo_dir="${src_root}"/apt_signed
    mkdir -p "${repo_dir}"

    cp -r "${KOKORO_GFILE_DIR}"/apt_unsigned/* "${repo_dir}"

    # Sign the Release file(s).
    local release_file
    for release_file in "${repo_dir}"/dists/*/Release; do
        /escalated_sign/escalated_sign.py --tool=linux_gpg_sign \
                                          --job-dir=/escalated_sign_jobs -- \
                                          --loglevel=debug \
                                          "${release_file}"

        mv "${release_file}.asc" "${release_file}.gpg"
    done

    # Sign the debs.
    local deb
    find "${repo_dir}/pool" -name "*.deb" -exec \
        /escalated_sign/escalated_sign.py --tool=linux_gpg_sign \
                                          --job-dir=/escalated_sign_jobs -- \
                                          --loglevel=debug \
                                          {} \;
}

main "$@"
