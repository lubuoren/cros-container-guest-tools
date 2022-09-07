#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -eux

ensure_repo() {
    local package="$1"

    if [[ ! -d "${package}" ]]; then
        echo "ERROR: repository ${package} is missing." >& 2
        exit 1
    fi
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

    for package in "$@"; do
        case "${package}" in
          waffle)
            untar_package "${package}"
            ;;
          *)
            ensure_repo "${package}"
            ;;
        esac
    done
}

main "$@"
