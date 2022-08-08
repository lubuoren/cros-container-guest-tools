#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
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

    # Add buster specific packages
    if [ "${release}" = "buster" ]; then
        cat > /etc/apt/preferences.d/waffle.pref << EOD
Package: *
Pin: release a=testing
Pin-Priority: 400
Explanation: Prioritize testing version

Package: libwaffle-1-0
Pin: release a=testing
Pin-Priority: 505
Explanation: Prioritize testing version

Package: libwaffle-dev
Pin: release a=testing
Pin-Priority: 505
Explanation: Prioritize testing version
EOD

        echo "deb [trusted=yes] http://deb.debian.org/debian/ testing main" > /etc/apt/sources.list.d/testing.list
        echo "deb [trusted=yes] file:///run/apt ${release} main" > /etc/apt/sources.list.d/cros-mesa.list
    fi
    apt-get update

    # For crostini.AudioBasic.
    apt-get -q -y install alsa-utils

    # For crostini.CpuPerf.
    apt-get -q -y install lmbench

    # For crostini.DiskIOPerf.
    apt-get -q -y install fio

    # For crostini.InputLatency.
    apt-get -q -y install python2.7

    # For crostini.NetworkPerf.
    apt-get -q -y install iperf3 iputils-ping

    # For crostini.Toolkit.*.
    apt-get -q -y install python3-gi python3-gi-cairo gir1.2-gtk-3.0 # GTK3
    apt-get -q -y install python3-pyqt5                              # Qt5
    apt-get -q -y install python3-tk                                 # Tkinter

    # For crostini.VimCompile.
    apt-get -q -y install gcc make libncurses5-dev libncursesw5-dev # Compilation toolchain

    # For crostini.Webserver.
    apt-get -q -y install busybox

    # For graphics.CrostiniTrace*.
    apt-get -q -y install mesa-utils apitrace zstd

    # For filemanager.SMB.
    echo "samba-common samba-common/workgroup string WORKGROUP" \
      | debconf-set-selections
    echo "samba-common samba-common/dhcp boolean true" \
      | debconf-set-selections
    echo "samba-common samba-common/do_debconf boolean true" \
      | debconf-set-selections
    apt-get -q -y install samba

    # For crostini.Notify
    apt-get -q -y install libnotify-bin

    # For graphics.GLBench
    if [ "${release}" = "buster" ]; then
        apt-get -q -y install glbench
        apt-get clean
        rm /etc/apt/sources.list.d/cros-mesa.list
        apt-get update
    fi
}

main "$@"
