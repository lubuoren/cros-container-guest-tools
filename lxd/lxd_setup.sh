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
    sed -i 's|http:|https:|g' /etc/apt/sources.list

    echo "deb [trusted=yes] file:///run/apt ${release} main" >/etc/apt/sources.list.d/cros-staging.list

    apt-get update

    # python3 is used for integration testing.
    apt-get -q -y --no-install-recommends install python3
    if [ "${release}" = "stretch" ]; then
        # gnome-icon-theme_3.12.0-2 sometimes gets checksum failures when
        # installing from deb.debian.org, use our own known-good copy, with
        # lots of extra debugging so we can try and figure out the cause,
        # and retry up to 5 times to try and keep the build going.
        # Buster has a newer version we haven't seen failures on, so this will
        # go away when we can stop supporting Stretch.
        set +e
        for attempt in {1..5}; do
            apt-get -q -y --no-install-recommends -o Debug::Hashes=true \
                -o Debug::pkgAcquire::Auth=true -o Debug::pkgDPkgPM=true \
                install /extra-debs/gnome-icon-theme_3.12.0-2_all.deb && break
        done
        set -e
        if [[ "${attempt}" -eq 5 ]]; then
            # Failed to install, try again without apt and even more verbose.
            # Like, really verbose, but not quite the most verbose.
            dpkg -D73333 -i /extra-debs/gnome-icon-theme_3.12.0-2_all.deb
        fi

        # The cros-gpu package installs more apt sources.
        apt-get -q -y --allow-unauthenticated install cros-gpu
        apt-get update
    fi

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
