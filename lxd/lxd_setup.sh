#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container. This is run from inside the container as root.

set -eux

main() {
    apt-get update
    apt-get -q -y install apt-transport-https

    cat >/etc/apt/sources.list.d/cros-staging.list <<EOF
deb file:///run/apt stretch main
EOF

    apt-get update
    # unattended-upgrades recommends a mail agent; don't install that.
    apt-get -q -y --no-install-recommends install cros-unattended-upgrades
    apt-get -q -y install cros-guest-tools
    apt-get -q -y install less

    apt-get clean
    rm /etc/apt/sources.list.d/cros-staging.list
    apt-get update

    # Don't run sshd out of the box.
    touch /etc/ssh/sshd_not_to_be_run
}

main "$@"
