#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container. This is run from inside the container as root.

set -eux

main() {
    local release=$1
    apt-get update
    apt-get -q -y install apt-transport-https ca-certificates

    # Use HTTPS repos.
    sed -i 's|http|https|g' /etc/apt/sources.list
    # Use deb.debian.org redirection; security.debian.org doesn't handle HTTPS.
    sed -i 's|security.debian.org|deb.debian.org|g' /etc/apt/sources.list

    echo "deb [trusted=yes] file:///run/apt ${release} main" >/etc/apt/sources.list.d/cros-staging.list

    apt-get update
    # python3 is used for integration testing.
    apt-get -q -y --no-install-recommends install python3
    apt-get -q -y --allow-unauthenticated install cros-guest-tools
    apt-get -q -y install less

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
