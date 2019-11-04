#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

# This script makes use of the following environment variables defined
# in the Dockerfile:
# - ARCHES
# - ARTIFACTS
# - DISTRIBUTIONS
# - PACKAGES

make_tarball() {
    local package="$1"

    pushd "${package}" >/dev/null

    local ver="$(dpkg-parsechangelog | \
                 awk '/^Version:/ {print $2}' | \
                 sed 's/-.*$//')"
    git archive --format=tar HEAD \
        --prefix="${package}-${ver}/" | \
        gzip -9 > "../${package}_${ver}.orig.tar.gz"

    popd >/dev/null
}

build_packages() {
    local dist="$1"
    local arch="$2"
    local package="$3"

    pushd "${package}" >/dev/null

    DIST="${dist}" ARCH="${arch}" \
        pdebuild --debbuildopts "-i -d" \
            --buildresult "${ARTIFACTS}" \
            -- \
            --distribution "${dist}" \
            --architecture "${arch}" \
            --basetgz "/var/cache/pbuilder/base-${arch}.tgz"

    popd >/dev/null
}

main() {
    # Packages stored here will be accessible outside of the build as well
    # as used for buildpackages of subsequent packages (via hooks).
    mkdir -p "${ARTIFACTS}"

    local package
    local dist
    local arch

    # PACKAGES, DISTRIBUTIONS, and ARCHES are passed by docker environment as
    # scalars.
    for package in ${PACKAGES}; do
        case "${package}" in
          apitrace|glbench)
            make_tarball "${package}"
            ;;
        esac

        for dist in ${DISTRIBUTIONS}; do
            for arch in ${ARCHES}; do
                build_packages "${dist}" "${arch}" "${package}"
            done
        done
    done
}

main "$@"
