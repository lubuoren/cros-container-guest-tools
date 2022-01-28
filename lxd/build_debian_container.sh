#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

DISTROBUILDER="/usr/local/bin/distrobuilder"

cleanup() {
    local tempdir="$1"
    local rootfs="$2"

    unmount_all "${rootfs}" || true
    # Unmounting may fail because paths were not mounted.
    # Cleanup is skipped if any mounted paths remain in the rootfs.
    if grep -F -q "${rootfs}" /proc/self/mounts; then
        echo "Failed to unmount filesystems, skipping cleanup of ${tempdir}."
        exit 1
    fi

    rm -rf "${tempdir}"
}

unmount_all() {
    local rootfs="$1"

    umount "${rootfs}/tmp"
    umount "${rootfs}/run"
    umount "${rootfs}/proc"
    umount "${rootfs}/dev"
    umount "${rootfs}/etc/resolv.conf"
    umount "${rootfs}/opt/google/cros-containers"
}

build_containers() {
    local arch=$1
    local src_root=$2
    local results_dir=$3
    local apt_dir=$4
    local release=$5

    local tempdir
    tempdir="$(mktemp -d)"

    local rootfs="${tempdir}/rootfs"
    trap "cleanup \"${tempdir}\" \"${rootfs}\"" EXIT

    # build-dir only creates a rootfs, rather than build the LXD image.
    # We pack the image later, so we can re-use the rootfs for each image type.
    "${DISTROBUILDER}" build-dir "${src_root}/lxd/debian.yaml" "${rootfs}" \
        -o "image.architecture=${arch}" \
        -o "image.release=${release}"

    # Make dummy sommelier paths for update-alternatives.
    local dummy_path="${tempdir}/cros-containers"
    mkdir -p "${dummy_path}"/{bin,lib}
    touch "${dummy_path}"/bin/sommelier
    touch "${dummy_path}"/lib/swrast_dri.so
    touch "${dummy_path}"/lib/virtio_gpu_dri.so

    for image_type in "prod" "test" "app_test"; do
        build_and_export "${arch}" \
                         "${src_root}" \
                         "${rootfs}" \
                         "${image_type}" \
                         "${release}" \
                         "${results_dir}" \
                         "${apt_dir}"
    done
}

build_and_export() {
    local arch=$1
    local src_root=$2
    local rootfs=$3
    local image_type=$4
    local release=$5
    local results_dir=$6
    local apt_dir=$7

    mkdir -p "${rootfs}/opt/google/cros-containers"
    mount --bind "${dummy_path}" "${rootfs}/opt/google/cros-containers"
    mount --bind /run/resolvconf/resolv.conf "${rootfs}/etc/resolv.conf"
    mount --bind /dev "${rootfs}/dev"
    mount -t proc none "${rootfs}/proc"
    mount -t tmpfs tmpfs "${rootfs}/run"
    mount -t tmpfs tmpfs "${rootfs}/tmp"

    mkdir "${rootfs}/run/apt"
    cp -r "${apt_dir}"/* "${rootfs}/run/apt"

    if [ "${image_type}" = "prod" ]; then
        local setup_script="${src_root}"/lxd/lxd_setup.sh
        cp "${setup_script}" "${rootfs}/run/"
        chroot "${rootfs}" /run/"$(basename ${setup_script})" \
            "${release}"
    fi

    if [ "${image_type}" = "test" ]; then
        local setup_test_script="${src_root}"/lxd/lxd_test_setup.sh
        cp "${setup_test_script}" "${rootfs}/run/"
        chroot "${rootfs}" /run/"$(basename ${setup_test_script})" \
            "${release}"
    fi

    if [ "${image_type}" = "app_test" ]; then
        local setup_test_app_script="${src_root}"/lxd/lxd_test_app_setup.sh
        cp "${setup_test_app_script}" "${rootfs}/run/"
        chroot "${rootfs}" /run/"$(basename ${setup_test_app_script})" \
            "${arch}"
    fi

    unmount_all "${rootfs}"
    rm -rf "${rootfs}/opt/google"

    # Pack into a tarball + squashfs for distribution via simplestreams.
    # Combined sha256 is lxd.tar.xz | rootfs.
    # rootfs.squashfs is raw rootfs squash'd.
    # lxd.tar.xz is metadata.yaml and templates dir.
    local result_dir="${results_dir}/debian/${release}/${arch}"
    if [ "${image_type}" = "test" ]; then
        result_dir="${result_dir}/test"
    elif [ "${image_type}" = "app_test" ]; then
        result_dir="${result_dir}/app_test"
    else
        result_dir="${result_dir}/default"
    fi
    mkdir -p "${result_dir}"

    local metadata_tarball="${result_dir}/lxd.tar.xz"
    local rootfs_image="${result_dir}/rootfs.squashfs"

    pushd "${result_dir}" > /dev/null

    "${DISTROBUILDER}" pack-lxd "${src_root}/lxd/debian.yaml" "${rootfs}" \
        -o "image.architecture=${arch}" \
        -o "image.release=${release}" \
        -o "image.variant=${image_type}"

    popd > /dev/null

    if [ "${arch}" = "amd64" ] && [ "${image_type}" == "prod" ]; then
        "${src_root}"/lxd/test.py "${results_dir}" \
                                  "${metadata_tarball}" \
                                  "${rootfs_image}"
    fi
}

main() {
    local src_root=$1
    local results_dir=$2
    local apt_dir=$3
    local arch=$4
    local release=$5

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

    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root to repack rootfs tarballs."
        return 1
    fi

    build_containers "${arch}" \
                     "${src_root}" \
                     "${results_dir}" \
                     "${apt_dir}" \
                     "${release}"
}

main "$@"
