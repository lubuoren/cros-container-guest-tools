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

    # For webserver testing.
    apt-get -q -y install python2.7

    # For vm.CrostiniDiskIOPerf.
    apt-get -q -y install fio

    # For vm.CrostiniNetworkPerf.
    apt-get -q -y install iperf3 iputils-ping

    # For vm.CrostiniCpuPerf.
    apt-get -q -y install lmbench
}

main "$@"
