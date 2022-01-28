#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

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
    # Remove CUDA sources before updating (b/139349554).
    sudo rm -f /etc/apt/sources.list.d/cuda.list*

    sudo apt-get -q update

    # LXD setup. Use the stable snap version.
    sudo apt-get install -q -y snapd
    sudo snap install lxd --channel=4.0/stable
    sudo snap start lxd
    sudo /snap/bin/lxd waitready

    # qemu setup.
    if [[ $(get_arch) == "arm64" ]]; then
        sudo apt-get install -q -y libpipeline1 lsb-base
        sudo dpkg --install "${KOKORO_GFILE_DIR}"/binfmt-support.deb
        sudo dpkg --install "${KOKORO_GFILE_DIR}"/qemu-user-static.deb
    fi

    # Debootstrap from Ubuntu 16.04 is too old. Install the version shipped
    # with Debian 11.
    sudo dpkg --install "${KOKORO_GFILE_DIR}/debootstrap_1.0.123_all.deb"

    # Distrobuilder requires Go >= 1.13
    go get golang.org/dl/go1.17

    GOPATH="$(go env GOPATH)"
    GO="${GOPATH}/bin/go1.17"
    ${GO} download
    GOROOT_1_17="$(${GO} env GOROOT)"

    pushd /tmp

    curl "https://linuxcontainers.org/downloads/distrobuilder/${DISTROBUILDER_ARCHIVE}" -O
    sha256sum --check <<< "${DISTROBUILDER_SHA256SUM}  ${DISTROBUILDER_ARCHIVE}"
    tar xf "${DISTROBUILDER_ARCHIVE}"
    cd "$(basename -s .tar.gz "${DISTROBUILDER_ARCHIVE}")"
    GOROOT="${GOROOT_1_17}" PATH="${GOROOT_1_17}/bin:${PATH}" make
    # Copy the distrobuilder binary from the user's GOPATH to a system location.
    sudo install "${GOPATH}/bin/distrobuilder" /usr/local/bin/distrobuilder
    popd

    # Install python dependencies for testing.
    sudo pip3 install unittest-xml-reporting
    sudo pip3 install pylxd==2.2.11

    # Patch pylxd incompatibility with Python 3.5.
    pushd /usr/local/lib/python3.5/dist-packages/pylxd/models > /dev/null
    sudo patch -p1 << EOF
diff --git a/image.py b/image.py
index f1e60df..00429ee 100644
--- a/image.py
+++ b/image.py
@@ -122,9 +122,10 @@ class Image(model.Model):
             # Image uploaded as chunked/stream (metadata, rootfs)
             # multipart message.
             # Order of parts is important metadata should be passed first
-            files = collections.OrderedDict(
-                metadata=('metadata', metadata, 'application/octet-stream'),
-                rootfs=('rootfs', image_data, 'application/octet-stream'))
+            files = collections.OrderedDict((
+                ('metadata', ('metadata', metadata, 'application/octet-stream')),
+                ('rootfs', ('rootfs', image_data, 'application/octet-stream'))
+            ))
             data = MultipartEncoder(files)
             print(data)
             headers.update({"Content-Type": data.content_type})
EOF
    popd > /dev/null
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
