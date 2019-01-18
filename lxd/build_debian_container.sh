#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

LXD="/snap/bin/lxd"
LXC="/snap/bin/lxc"

build_container() {
    local arch=$1
    local src_root=$2
    local results_dir=$3
    local apt_dir=$4
    local test_image=$5
    local release=$6

    local setup_script="${src_root}"/lxd/lxd_setup.sh
    local setup_test_script="${src_root}"/lxd/lxd_test_setup.sh

    local base_image="images:debian/${release}/${arch}"
    local tempdir="$(mktemp -d)"
    ${LXC} image export "${base_image}" "${tempdir}/image"

    local rootfs="${tempdir}/rootfs"
    unsquashfs -d "${rootfs}" "${tempdir}/image.root"

    if [ "${arch}" = "arm64" ]; then
        cp /usr/bin/qemu-aarch64-static "${rootfs}/usr/bin/"
    fi

    mkdir -p "${rootfs}/opt/google/cros-containers"
    mount --bind /tmp/cros-containers "${rootfs}/opt/google/cros-containers"
    mount --bind /run/resolvconf/resolv.conf "${rootfs}/etc/resolv.conf"
    mount --bind /dev/pts "${rootfs}/dev/pts"
    mount -t proc none "${rootfs}/proc"
    mount -t tmpfs tmpfs "${rootfs}/run"
    mount -t tmpfs tmpfs "${rootfs}/tmp"

    cp "${setup_script}" "${setup_test_script}" "${rootfs}/run/"
    mkdir "${rootfs}/run/apt"
    cp -r "${apt_dir}"/* "${rootfs}/run/apt"

    chroot "${rootfs}" /run/"$(basename ${setup_script})" "${release}"

    if [ "${test_image}" = true ]; then
        chroot "${rootfs}" /run/"$(basename ${setup_test_script})"
    fi

    umount "${rootfs}/tmp"
    umount "${rootfs}/run"
    umount "${rootfs}/proc"
    umount "${rootfs}/dev/pts"
    umount "${rootfs}/etc/resolv.conf"
    umount "${rootfs}/opt/google/cros-containers"
    rm -rf "${rootfs}/opt/google"
    if [ "${arch}" = "arm64" ]; then
        rm "${rootfs}/usr/bin/qemu-aarch64-static"
    fi

    # Repack into 2 tarballs + squashfs for distribution via simplestreams.
    # Combined sha256 is lxd.tar.xz | rootfs.
    # rootfs.tar.xz is raw rootfs tar'd up.
    # rootfs.squashfs is raw rootfs squash'd.
    # lxd.tar.xz is metadata.yaml and templates dir.
    local result_dir="${results_dir}/debian/${release}/${arch}"
    if [ "${test_image}" = true ]; then
        result_dir="${result_dir}/test"
    else
        result_dir="${result_dir}/default"
    fi
    mkdir -p "${result_dir}"

    local metadata_tarball="${result_dir}/lxd.tar.xz"
    local rootfs_tarball="${result_dir}/rootfs.tar.xz"
    cp "${tempdir}/image" "${metadata_tarball}"
    tar -Ipixz -cpf "${rootfs_tarball}" -C "${rootfs}" .
    mksquashfs "${rootfs}"/* "${result_dir}/rootfs.squashfs"

    if [ "${arch}" = "amd64" ] && [ "${test_image}" != true ]; then
        # Workaround the "Invalid multipart image" flake by generating a
        # single tarball.
        tar xvf "${tempdir}/image" -C "${tempdir}"
        tar -Ipixz -cpf "${tempdir}/unified.tar.xz" \
            -C "${tempdir}" rootfs metadata.yaml templates
        "${src_root}"/lxd/test.py "${results_dir}" \
                                  "${tempdir}/unified.tar.xz"
    fi

    rm -rf "${tempdir}"
}

main() {
    local src_root=$1
    local results_dir=$2
    local apt_dir=$3
    local job_name=$4

    if [ -z "${results_dir}" -o ! -d "${results_dir}" ]; then
        echo "Results directory '${results_dir}' doesn't exist."
        return 1
    fi

    if [ ! -d "${src_root}" ]; then
        echo "Source root '${src_root}' doesn't exist."
        return 1
    fi

    if [ ! -d "${apt_dir}" ]; then
        echo "Apt repo directory '${apt_dir}' doesn't exist."
        return 1
    fi

    if [ -z "${job_name}" ]; then
        echo "Job name should be specified"
        return 1
    fi

    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root to repack rootfs tarballs."
        return 1
    fi

    # Make dummy sommelier paths for update-alternatives.
    local dummy_path="/tmp/cros-containers"
    mkdir -p "${dummy_path}"/{bin,lib}
    touch "${dummy_path}"/bin/sommelier
    touch "${dummy_path}"/lib/swrast_dri.so

    # If doing presubmit, only run tests.
    if [[ $job_name = *"presubmit"* ]]; then
        build_container "amd64" \
                        "${src_root}" \
                        "${results_dir}" \
                        "${apt_dir}" \
                        false \
                        stretch
        build_container "amd64" \
                        "${src_root}" \
                        "${results_dir}" \
                        "${apt_dir}" \
                        true \
                        stretch
        build_container "amd64" \
                        "${src_root}" \
                        "${results_dir}" \
                        "${apt_dir}" \
                        true \
                        buster
        exit 0
    fi

    # Build the normal and test images for each arch.
    for arch in amd64 arm64; do
        for release in stretch buster; do
            for test_image in false true; do
                build_container "${arch}" \
                                "${src_root}" \
                                "${results_dir}" \
                                "${apt_dir}" \
                                "${test_image}" \
                                "${release}"
            done
        done
    done
}

main "$@"
