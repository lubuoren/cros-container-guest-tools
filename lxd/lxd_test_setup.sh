#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux

main() {
    apt-get update

    # For X11 and wayland testing.
    apt-get -q -y install gnome-mahjongg gimp

    # For webserver testing.
    apt-get -q -y install python2.7
}

main "$@"
