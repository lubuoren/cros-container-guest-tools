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

    local CHROMIUMOS="https://chromium.googlesource.com/chromiumos/"
    local THIRD_PARTY="${CHROMIUMOS}/third_party"
    local PLATFORM="${CHROMIUMOS}/platform"

    if [[ ! -d "${package}" ]]; then
        case "${package}" in
          apitrace|libdrm|mesa)
            repo="${THIRD_PARTY}/${package}"
            ;;
          glbench)
            repo="${PLATFORM}/${package}"
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

untar_package() {
    local package="$1"

    local DISTFILES="http://commondatastorage.googleapis.com/chromeos-localmirror/crostini/distfiles"

    local orig
    local debian
    if [[ ! -d "${package}" ]]; then
        case "${package}" in
          waffle)
            orig="1.6.0"
            debian="1.6.0-4"
            ;;
          *)
            echo "ERROR: unable to untar unknown package ${package}"
            exit 1
            ;;
        esac
    fi

    wget "${DISTFILES}/${package}_${orig}.orig.tar.xz"
    wget "${DISTFILES}/${package}_${debian}.debian.tar.xz"
    mkdir "${package}"
    tar -C "${package}" --strip-components=1 -xf \
        "${package}_${orig}.orig.tar.xz"
    tar -C "${package}" -xf "${package}_${debian}.debian.tar.xz"
}

main() {
    local package

    # PACKAGES is passed by docker environment as scalar.
    for package in ${PACKAGES}; do
        case "${package}" in
          waffle)
            untar_package "${package}"
            ;;
          *)
            clone_repo "${package}" "${MESA_CHECKOUT_BRANCH}"
            create_branch "${package}" "${MESA_BUILD_BRANCH}"
            ;;
        esac
    done
}

main "$@"
