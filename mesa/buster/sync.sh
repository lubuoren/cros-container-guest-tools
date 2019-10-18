#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - MESA_BUILD_BRANCH - The name of the branch created to build
# - MESA_CHECKOUT_BRANCH - The branch checked out from the origin if cloning
# - PACKAGES

clone_repo() {
    local package="$1"
    local branch="$2"

    local repo

    local THIRD_PARTY="https://chromium.googlesource.com/chromiumos/third_party"

    if [[ ! -d "${package}" ]]; then
        case "${package}" in
          apitrace|mesa)
            repo="${THIRD_PARTY}/${package}"
            ;;
          *)
            echo "ERROR: unable to sync unknown package ${package}"
            exit 1
            ;;
        esac

        git clone "${repo}"
        (cd "${package}" && git checkout origin/"${branch}")
    fi
}

create_branch() {
    local package="$1"
    local branch="$2"

    (cd "${package}" && git checkout -B "${branch}")
}

main() {
    local package

    # PACKAGES is passed by docker environment as scalar.
    for package in ${PACKAGES}; do
        clone_repo "${package}" "${MESA_CHECKOUT_BRANCH}"
        create_branch "${package}" "${MESA_BUILD_BRANCH}"
    done
}

main "$@"
