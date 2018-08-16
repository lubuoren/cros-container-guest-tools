#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

RELEASE=stretch

main() {
    if [ -z "${KOKORO_ARTIFACTS_DIR}" ]; then
        echo "This script must be run in kokoro"
        exit 1
    fi

    local src_root="${KOKORO_ARTIFACTS_DIR}/git/cros-container-guest-tools"
    local repo_dir="${src_root}"/apt_unsigned
    mkdir -p "${repo_dir}"/{,conf}

    cat > "${repo_dir}/conf/distributions" <<EOF
Origin: Google
Label: cros-containers
Suite: stable
Codename: stretch
Version: 1.0
Architectures: amd64 arm64 armhf i386
Components: main
Description: CrOS containers guest tools
EOF

    local deb
    for deb in ""${KOKORO_GFILE_DIR}/guest_debs/*.deb; do
        reprepro -b "${repo_dir}" includedeb "${RELEASE}" "${deb}"
    done
}

main "$@"
