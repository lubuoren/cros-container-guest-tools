#!/bin/bash
# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -eux

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
    local buildresult="$3"
    local package="$4"

    pushd "${package}" >/dev/null

    DIST="${dist}" ARCH="${arch}" DEPSBASE="${buildresult}" \
        pdebuild --debbuildopts "-i -d" \
            --buildresult "${buildresult}" \
            -- \
            --distribution "${dist}" \
            --architecture "${arch}" \
            --basetgz "/var/cache/pbuilder/base-${arch}.tgz"

    popd >/dev/null
}

# Rebuild a package as binNMU (https://wiki.debian.org/binNMU)
build_packages_binnmu() {
    local dist="$1"
    local arch="$2"
    local buildresult="$3"
    local package="$4"
    local nmu="$5"
    local nmu_maintainer="$6"
    local nmu_version="$7"
    local nmu_timestamp="$8"

    pushd "${package}" >/dev/null

    DIST="${dist}" ARCH="${arch}" DEPSBASE="${buildresult}" \
        pdebuild --debbuildopts "-i -d" \
            --buildresult "${buildresult}" \
            -- \
            --distribution "${dist}" \
            --architecture "${arch}" \
            --basetgz "/var/cache/pbuilder/base-${arch}.tgz" \
            --bin-nmu "${nmu}" \
            --bin-nmu-maintainer "${nmu_maintainer}" \
            --bin-nmu-version "${nmu_version}" \
            --bin-nmu-timestamp "${nmu_timestamp}"

    popd >/dev/null
}

main() {
    local dist="$1"
    local arch="$2"
    local buildresult="$3"
    shift 3
    local packages=( "$@" )

    local package
    for package in "${packages[@]}"; do
        case "${package}" in
          apitrace|glbench)
            make_tarball "${package}"
            ;;
        esac

        case "${package}" in
          waffle)
            build_packages_binnmu "${dist}" "${arch}" "${buildresult}" \
                "${package}" "Rebuild for ${dist}" \
                "David Riley <davidriley@chromium.org>" \
                1 "@1584995126"
            ;;
          *)
            build_packages "${dist}" "${arch}" "${buildresult}" "${package}"
            ;;
        esac
    done
}

main "$@"
