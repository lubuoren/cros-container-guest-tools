#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

DISTROBUILDER_ARCHIVE="distrobuilder-2.0.tar.gz"
DISTROBUILDER_SHA256SUM="9ddd9b13cbfc61b75ba8d2393df5b11be420145908f36aad7e47d464e8809147"

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
    sudo apt-get -q update

    local -a build_dependencies
    build_dependencies=( debootstrap golang-go )

    # qemu setup.
    if [[ "$(get_arch)" == "arm64" ]]; then
        build_dependencies+=( binfmt-support qemu-user-static )
    elif [[ "$(get_arch)" == "amd64" ]]; then
        build_dependencies+=( python3-venv )
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
        "${build_dependencies[@]}"

    GOPATH="$(go env GOPATH)"
    pushd /tmp
    curl "https://linuxcontainers.org/downloads/distrobuilder/${DISTROBUILDER_ARCHIVE}" -O
    sha256sum --check <<< "${DISTROBUILDER_SHA256SUM}  ${DISTROBUILDER_ARCHIVE}"
    tar xf "${DISTROBUILDER_ARCHIVE}"
    cd "$(basename -s .tar.gz "${DISTROBUILDER_ARCHIVE}")"
    make
    # Copy the distrobuilder binary from the user's GOPATH to a system location.
    sudo install "${GOPATH}/bin/distrobuilder" /usr/local/bin/distrobuilder
    popd
}

setup_test_venv() {
    local src_root="$1"
    local venv="$2"

    python3 -m venv "${venv}"
    source "${venv}/bin/activate"
    pip install "wheel==0.37.1"
    pip install -r "${src_root}/lxd/requirements.txt"
    deactivate
}

do_preseed() {
    sudo /snap/bin/lxd waitready
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
    stop_apt_daily

    local src_root="${KOKORO_ARTIFACTS_DIR}"/git/cros-container-guest-tools
    local result_dir="${src_root}"/lxd
    mkdir -p "${result_dir}"

    install_deps

    local apt_dir=""

    if [ -d "${KOKORO_GFILE_DIR}/apt_signed" ]; then
        apt_dir="${KOKORO_GFILE_DIR}/apt_signed"
    else
        apt_dir="${KOKORO_GFILE_DIR}/apt_unsigned"
    fi

    arch="$(get_arch)"
    release="$(get_release)"
    test_venv="${TMPDIR:-/tmp}/testenv"

    # Container tests only run on x86
    if [[ "${arch}" == "amd64" ]]; then
        do_preseed
        setup_test_venv "${src_root}" "${test_venv}"
    fi

    sudo "${src_root}/lxd/build_debian_container.sh" "${src_root}" \
                                                     "${result_dir}" \
                                                     "${apt_dir}" \
                                                     "${arch}" \
                                                     "${release}" \
                                                     "${test_venv}"
}

main "$@"
