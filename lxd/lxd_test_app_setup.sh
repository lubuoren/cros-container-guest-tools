#!/bin/bash
# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux -o pipefail

# To update this, run apt-cache policy code on your DUT with this
# container installed, and look at the latest version.
# Note that updating this package is likely to break screendiffs.
# Releases for different architectures have different build numbers.
VSCODE_VERSION_AMD64="1.63.0-1638855526"
VSCODE_VERSION_ARM64="1.63.0-1638854446"

main() {
    local arch=$1
    export DEBIAN_FRONTEND=noninteractive

    local -a packages
    packages=(
        audacity
        emacs
        firefox-esr
        gedit
    )

    # for testing Visual Studio Code.
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
    cat > /etc/apt/sources.list.d/vscode.list << EOF
deb [arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main
EOF

    if [ "${arch}" = "amd64" ]; then
        # for testing Android Studio.
        wget -q https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/android-studio-linux.tar.gz
        tar -xf android-studio-linux.tar.gz
        rm -f android-studio-linux.tar.gz

        # for testing Eclipse.
        packages+=( default-jre )
        wget -q https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/eclipse.tar.gz
        tar -xf eclipse.tar.gz -C /usr/
        ln -s /usr/eclipse/eclipse /usr/bin/eclipse
        rm -f eclipse.tar.gz

        packages+=( "code=${VSCODE_VERSION_AMD64}" )
    elif [ "${arch}" = "arm64" ]; then
        packages+=( "code=${VSCODE_VERSION_ARM64}" )
    fi

    apt-get -q update
    apt-get -q -y install "${packages[@]}"
}

main "$@"
