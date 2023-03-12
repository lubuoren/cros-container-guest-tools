#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

. "$(dirname "$0")/common.sh" || exit 1

get_arch() {
    basename "${KOKORO_JOB_NAME}" |
        sed 's/^lxd_container_//; s/_[[:alnum:]]\+$//'
}

get_release() {
    basename "${KOKORO_JOB_NAME}" |
        sed 's/^lxd_container_//; s/^[[:alnum:]]\+_//'
}

install_deps() {
    # Remove CUDA sources before updating (b/139349554).
    sudo rm -f /etc/apt/sources.list.d/cuda.list*

    sudo apt-get -q update

    # LXD setup. Use the latest snap version.
    sudo apt-get install -q -y snapd
    sudo snap install lxd --channel=3.0/stable
    sudo snap start lxd
    sudo /snap/bin/lxd waitready

    # qemu setup.
    if [[ $(get_arch) == "arm64" ]]; then
        sudo apt-get install -q -y libpipeline1 lsb-base
        sudo dpkg --install "${KOKORO_GFILE_DIR}"/binfmt-support.deb
        sudo dpkg --install "${KOKORO_GFILE_DIR}"/qemu-user-static.deb
    fi

    # pixz improves compression time for the rootfs significantly.
    sudo apt-get install -q -y pixz

    # Install python dependencies for testing.
    sudo pip3 install unittest-xml-reporting
    sudo pip3 install pylxd

    # TODO(smbarber): Install via pip once container.execute's regression is
    # fixed. https://github.com/lxc/pylxd/pull/321
    pushd /tmp

    git clone https://github.com/lxc/pylxd.git
    cd pylxd
    git checkout 23cef05b0e0b0c8605deb92c070139cd8246a416
    sudo python3 setup.py install

    popd
}

do_preseed() {
    cat <<EOF | sudo /snap/bin/lxd init --preseed
# Storage pools
storage_pools:
- name: default
  driver: dir
  config:
    source: /var/snap/lxd/common/lxd/storage-pools/default

# Network
# IPv4 address is configured by the host.
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: auto

# Profiles
profiles:
- name: default
  config:
    boot.autostart: false
  devices:
    root:
      path: /
      pool: default
      type: disk
    eth0:
      nictype: bridged
      parent: lxdbr0
      type: nic
EOF
}

main() {
    require_kokoro_artifacts

    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/lxd
    mkdir -p "${result_dir}"

    install_deps
    do_preseed

    local apt_dir=""

    if [ -d "${KOKORO_GFILE_DIR}/apt_signed" ]; then
        apt_dir="${KOKORO_GFILE_DIR}/apt_signed"
    else
        apt_dir="${KOKORO_GFILE_DIR}/apt_unsigned"
    fi

    arch="$(get_arch)"
    release="$(get_release)"

    sudo "${src_root}/lxd/build_debian_container.sh" "${src_root}" \
                                                     "${result_dir}" \
                                                     "${apt_dir}" \
                                                     "${arch}" \
                                                     "${release}"
}

main "$@"
