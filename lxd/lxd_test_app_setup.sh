#!/bin/bash
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux

# To update this, run apt-cache policy code on your DUT with this
# container installed, and look at the latest version.
# Note that updating this package is likely to break screendiffs.
VSCODE_VERSION="1.63.0-1638855526"

main() {
    local arch=$1
    export DEBIAN_FRONTEND=noninteractive

    # for testing Gedit.
    apt-get -q -y install gedit

    # for testing Emacs.
    apt-get -q -y install emacs

    if [ "${arch}" = "amd64" ]; then
        # for testing Android Studio.
        wget -q https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/android-studio-linux.tar.gz
        tar -xf android-studio-linux.tar.gz
        rm -f android-studio-linux.tar.gz

        # for testing Eclipse.
        apt-get -q -y install default-jre
        wget -q https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/eclipse.tar.gz
        tar -xf eclipse.tar.gz -C /usr/
        ln -s /usr/eclipse/eclipse /usr/bin/eclipse
        rm -f eclipse.tar.gz

        # for testing Visual Studio Code.
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
            | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
        cat > /etc/apt/sources.list.d/vscode.list << EOF
deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main
EOF
        apt-get -q update
        apt-get -q -y install "code=${VSCODE_VERSION}"
        apt-mark hold code
    fi
}

main "$@"
