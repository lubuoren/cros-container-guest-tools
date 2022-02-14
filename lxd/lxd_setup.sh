#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container. This is run from inside the container as root.

set -eux

main() {
    local release=$1
    export DEBIAN_FRONTEND=noninteractive

    echo "deb [trusted=yes] file:///run/apt ${release} main" >/etc/apt/sources.list.d/cros-staging.list

    apt-get update

    apt-get -q -y --allow-unauthenticated install cros-guest-tools

    apt-get clean
    rm /etc/apt/sources.list.d/cros-staging.list
    apt-get update

    # Don't run sshd out of the box.
    touch /etc/ssh/sshd_not_to_be_run

    # Add a placeholder cros.list. This will be replaced at boot time by
    # tremplin.
    echo "deb https://storage.googleapis.com/cros-packages/74 stretch main"
}

main "$@"
