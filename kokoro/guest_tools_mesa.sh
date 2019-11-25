#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

. "$(dirname "$0")/common.sh" || exit 1
. "$(dirname "$0")/common_build.sh" || exit 1

# Determines the target which this shard should build based on the name of the
# kokoro job.
get_shard_target() {
    basename "${KOKORO_JOB_NAME}" | sed 's/^gtm_//'
}

main() {
    require_kokoro_artifacts

    # This script runs in all the .deb-building shards, so we process the kokoro
    # job name to determine what this shard is supposed to build.
    local shard_target=$(get_shard_target)
    echo "shard target=${shard_target}"
    if [[ ${shard_target} == "guest_tools_mesa" ]]; then
      # To preserve historic behaviour, we retain this target. It will be
      # invoked by the normal (non-sharded) build job.
      build_guest_tools
      build_mesa
    elif [[ ${shard_target} == "guest_tools" ]]; then
      build_guest_tools
    else
      # We convert the shard_target ("distro_arch_pkg1_pkg2...") into arguments
      # for building the shard.
      build_mesa_shard $(echo ${shard_target} | tr '_' ' ')
    fi
}

main "$@"
