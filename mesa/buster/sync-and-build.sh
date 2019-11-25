#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# A number of environment variables are defined in the Dockerfile and used
# by the resulting scripts to allow this same docker image to optionally
# cache the setupchroot step and keep all the configuration in a singular
# place.

main() {
    ./setupchroot.sh
    ./sync.sh
    ./buildpackages.sh
}

main "$@"
