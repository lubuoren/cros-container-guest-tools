#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux

main() {
    # Add non-free repository to apt sources.list.
    sed -E -i 's|^(deb.*main)$|\1 non-free|g' /etc/apt/sources.list

    apt-get update

    # For crostini.AudioSanity.
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

    # For crostini.Webserver.
    apt-get -q -y install busybox

    # For graphics.CrostiniTrace*.
    apt-get -q -y install mesa-utils apitrace zstd
}

main "$@"
