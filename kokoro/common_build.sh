#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

build_guest_tools() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/guest_debs
    mkdir -p "${result_dir}"

    # TODO(crbug.com/1060811): This is a hack to get around a kokoro bug. Remove
    # it when it is no longer necessary.
    rm -rf "/home/kbuilder/.cache/bazel/_bazel_kbuilder/install/4cfcf40fe067e89c8f5c38e156f8d8ca"

    cd "${src_root}"

    # Default is 0.23, we need at least 0.27. But go all the way to 4.2.1 since
    # (as of 2021-09-09) it's what's on our desktops.
    use_bazel.sh 4.2.1
    # Build all targets.
    bazel build //cros-debs:debs

    # Copy resulting debs to results directory.
    chmod 644 bazel-bin/cros-debs/*/*.deb
    cp -r bazel-bin/cros-debs/* "${result_dir}"
}

# Builds one of the mesa-related tools. Usage is:
#     build_mesa_shard <distro> <architecture> [<package> ...]
# Which will build <package> for the <distro> debian version with the given
# processor <architecture>.
build_mesa_shard() {
    [[ $# -ge 3 ]]
    local dist="$1"
    local arch="$2"
    shift 2
    local pkg="$@"
    local base_image="buildmesa_${dist}"
    local base_image_tarball="${KOKORO_GFILE_DIR}"/"${base_image}".tar.xz

    if [[ -z $(docker images -q "${base_image}" 2> /dev/null) ]]; then
        docker load -i "${base_image_tarball}"
    fi

    docker run \
      --rm \
      --privileged \
      --volume "${KOKORO_ARTIFACTS_DIR}/${dist}_mesa_debs":/artifacts \
      --volume "${KOKORO_ARTIFACTS_DIR}/git/mesa":/scratch/mesa \
      --env ARCHES="${arch}" \
      --env PACKAGES="${pkg}" \
      "${base_image}" \
      ./sync-and-build.sh
}
