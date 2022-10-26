#!/bin/bash
# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

build_guest_tools() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/guest_debs
    mkdir -p "${result_dir}"

    cd "${src_root}"

    curl -sSL https://bazel.build/bazel-release.pub.gpg \
        | gpg --dearmor \
        | sudo tee /etc/apt/trusted.gpg.d/bazel.gpg > /dev/null

    sudo tee /etc/apt/sources.list.d/bazel.list > /dev/null << EOF
deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/bazel.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8
EOF
    sudo apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
        bazel-5.3.0 python-is-python3

    # Build all targets.
    bazel-5.3.0 build //cros-debs:debs

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
    local packages=( "$@" )
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local buildresult="${KOKORO_ARTIFACTS_DIR}/${dist}_mesa_debs"
    mkdir -p "${buildresult}"

    local -a build_deps
    build_deps=( debhelper debian-archive-keyring pbuilder quilt )
    sudo apt-get -q update

    if [[ "${arch}" = "arm"* ]]; then
         build_deps+=(
            "${KOKORO_GFILE_DIR}/qemu-user-static_ubuntu6.2_amd64.deb"
        )
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install "${build_deps[@]}"

    local cache_url="gs://pbuilder-apt-cache/debian-${dist}-${arch}"
    local cache_dir="/var/cache/pbuilder/debian-${dist}-${arch}/aptcache"
    sudo mkdir -p "${cache_dir}"
    sudo gsutil -m -q rsync "${cache_url}" "${cache_dir}"

    sudo mv "${src_root}/mesa/"{.pbuilder,.pbuilderrc} /root/
    # Backported build dependencies are needed for newer libdrm and mesa.
    # This hack omits them for other builds.
    if [[ "${packages[*]}" != "libdrm mesa" ]]; then
        sudo rm -f /root/.pbuilder/hooks/E01apt-preferences
    fi

    pushd "${KOKORO_ARTIFACTS_DIR}/git" > /dev/null

    sudo "${src_root}/mesa/sync-and-build.sh" "${dist}" "${arch}" \
      "${buildresult}" "${packages[@]}"

    sudo gsutil -m -q rsync "${cache_dir}" "${cache_url}"

    popd > /dev/null
}

# Builds the Crostini IME Debian package for all supported architectures.
build_cros_im() {
    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/platform2/vm_tools/cros_im
    local result_dir="${src_root}"/cros_im_debs
    mkdir -p "${result_dir}"
    cd "${src_root}"

    # Use qemu-user-static 1:6.2 since the version in Ubuntu 20.04 has a bug
    # that has not yet been patched (b/244998899).
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        "${KOKORO_GFILE_DIR}"/qemu-user-static_ubuntu6.2_amd64.deb \
        binfmt-support

    # This job builds multiple architectures of bullseye. Download caches for
    # all these arches.
    local cache_url="gs://pbuilder-apt-cache"
    local cache_dir="/var/cache/pbuilder/aptcache"
    sudo mkdir -p "${cache_dir}"
    sudo gsutil -m -q rsync -r -x 'debian-(?!bullseye).*$' "${cache_url}" \
        "${cache_dir}"

    sudo ./build-packages

    sudo gsutil -m -q rsync -r -x 'debian-(?!bullseye).*$' "${cache_dir}" \
        "${cache_url}"

    # Copy resulting debs to results directory.
    cp -r *_cros_im_debs "${result_dir}"
}
