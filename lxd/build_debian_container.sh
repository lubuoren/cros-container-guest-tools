#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

LXD="/snap/bin/lxd"
LXC="/snap/bin/lxc"

build_containers() {
    local arch=$1
    local src_root=$2
    local results_dir=$3
    local apt_dir=$4
    local release=$5

    local base_image="images:debian/${release}/${arch}"
    local tempdir="$(mktemp -d)"
    ${LXC} image export "${base_image}" "${tempdir}/image"

    local rootfs="${tempdir}/rootfs"
    unsquashfs -d "${rootfs}" "${tempdir}/image.root"
    chmod 0755 "${rootfs}"

    for image_type in "prod" "test" "app_test"; do
        build_and_export "${arch}" \
                         "${src_root}" \
                         "${rootfs}" \
                         "${image_type}" \
                         "${release}" \
                         "${results_dir}" \
                         "${apt_dir}"
    done

    rm -rf "${tempdir}"

}

build_and_export() {
    local arch=$1
    local src_root=$2
    local rootfs=$3
    local image_type=$4
    local release=$5
    local results_dir=$6
    local apt_dir=$7

    if [ "${arch}" = "arm64" ]; then
        cp /usr/bin/qemu-aarch64-static "${rootfs}/usr/bin/"
    fi
    mkdir -p "${rootfs}/opt/google/cros-containers"
    mount --bind /tmp/cros-containers "${rootfs}/opt/google/cros-containers"
    mount --bind /run/resolvconf/resolv.conf "${rootfs}/etc/resolv.conf"
    mkdir -p "${rootfs}/extra-debs"
    mount --bind /tmp/extra-debs "${rootfs}/extra-debs"
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

    umount "${rootfs}/tmp"
    umount "${rootfs}/run"
    umount "${rootfs}/proc"
    umount "${rootfs}/dev"
    umount "${rootfs}/extra-debs"
    rm -rf "${rootfs}/extra-debs"
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
    if [ "${image_type}" = "test" ]; then
        result_dir="${result_dir}/test"
    elif [ "${image_type}" = "app_test" ]; then
        result_dir="${result_dir}/app_test"
    else
        result_dir="${result_dir}/default"
    fi
    mkdir -p "${result_dir}"

    local metadata_tarball="${result_dir}/lxd.tar.xz"
    local rootfs_tarball="${result_dir}/rootfs.tar.xz"
    cp "${tempdir}/image" "${metadata_tarball}"
    tar -Ipixz --xattrs --acls -cpf "${rootfs_tarball}" -C "${rootfs}" .
    mksquashfs "${rootfs}"/* "${result_dir}/rootfs.squashfs"

    if [ "${arch}" = "amd64" ] && [ "${image_type}" == "prod" ]; then
        # Workaround the "Invalid multipart image" flake by generating a
        # single tarball.
        tar xvf "${tempdir}/image" -C "${tempdir}"
        tar -Ipixz -cpf "${tempdir}/unified.tar.xz" \
            -C "${tempdir}" rootfs metadata.yaml templates
        "${src_root}"/lxd/test.py "${results_dir}" \
                                  "${tempdir}/unified.tar.xz"
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

    # Make dummy sommelier paths for update-alternatives.
    local dummy_path="/tmp/cros-containers"
    mkdir -p "${dummy_path}"/{bin,lib}
    touch "${dummy_path}"/bin/sommelier
    touch "${dummy_path}"/lib/swrast_dri.so
    touch "${dummy_path}"/lib/virtio_gpu_dri.so

    build_containers "${arch}" \
                     "${src_root}" \
                     "${results_dir}" \
                     "${apt_dir}" \
                     "${release}"
}

main "$@"
