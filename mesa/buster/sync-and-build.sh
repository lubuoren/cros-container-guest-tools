#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -eux

main() {
  local dist="$1"
  local arch="$2"
  local buildresult="$3"
  shift 3
  local packages=( "$@" )
  local script_dir
  script_dir="$(dirname "$0")"

  "${script_dir}/setupchroot.sh" "${dist}" "${arch}" "${buildresult}"
  "${script_dir}/sync.sh" "${packages[@]}"
  "${script_dir}/buildpackages.sh" "${dist}" "${arch}" "${buildresult}" \
    "${packages[@]}"
}

main "$@"
