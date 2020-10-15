#!/bin/bash
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set up a Debian container for test.
# This is run from inside the container as root.

set -eux

main() {
    local arch=$1

    # for testing Gedit.
    apt-get -q -y install gedit

    # for testing Emacs.
    apt-get -q -y install emacs

    if [ "${arch}" = "amd64" ]; then
        # for testing Android Studio.
        wget https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/android-studio-linux.tar.gz
        tar -zxvf android-studio-linux.tar.gz
        rm -f android-studio-linux.tar.gz

        # for testing Eclipse.
        apt-get -q -y install default-jre
        wget https://storage.googleapis.com/chromiumos-test-assets-public/crostini_test_files/eclipse.tar.gz
        tar -zxvf eclipse.tar.gz -C /usr/
        ln -s /usr/eclipse/eclipse /usr/bin/eclipse
        rm -f eclipse.tar.gz

        # for testing Visual Studio Code.
        apt-get -q -y install software-properties-common
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
        apt-get update
        apt-get -q -y install code
    fi
}

main "$@"
