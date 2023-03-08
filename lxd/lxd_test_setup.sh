#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux -o pipefail

main() {
    local release=$1
    export DEBIAN_FRONTEND=noninteractive
    # Add non-free repository to apt sources.list.
    sed -E -i 's|^(deb.*main)$|\1 non-free|g' /etc/apt/sources.list

    local -a packages
    packages=(
        # For crostini.AudioBasic.
        alsa-utils
        pulseaudio-utils
        # For crostini.CpuPerf.
        lmbench
        # For crostini.DiskIOPerf.
        fio
        # For crostini.InputLatency.
        xterm
        # For crostini.NetworkPerf.
        iperf3 iputils-ping
        # For crostini.Toolkit.*.
        python3-gi python3-gi-cairo gir1.2-gtk-3.0 # GTK3
        python3-pyqt5                              # Qt5
        python3-tk                                 # Tkinter
        # For crostini.VimCompile.
        gcc make libncurses5-dev libncursesw5-dev # Compilation toolchain
        # For crostini.Webserver.
        busybox
        # For graphics.CrostiniTrace*.
        mesa-utils apitrace zstd
        # For filemanager.SMB.
        samba
        # For crostini.Notify
        libnotify-bin
    )

    # For graphics.GLBench
    if [ "${release}" = "buster" ]; then
        echo "deb [trusted=yes] file:///run/apt ${release} main" > /etc/apt/sources.list.d/cros-mesa.list
        packages+=( glbench )
    fi

    # For filemanager.SMB.
    echo "samba-common samba-common/workgroup string WORKGROUP" \
      | debconf-set-selections
    echo "samba-common samba-common/dhcp boolean true" \
      | debconf-set-selections
    echo "samba-common samba-common/do_debconf boolean true" \
      | debconf-set-selections

    apt-get -o Acquire::Retries=3 update
    apt-get -o Acquire::Retries=3 -q -y install "${packages[@]}"

    if [ "${release}" = "buster" ]; then
        apt-get clean
        rm /etc/apt/sources.list.d/cros-mesa.list
        apt-get -o Acquire::Retries=3 update
    fi
}

main "$@"
