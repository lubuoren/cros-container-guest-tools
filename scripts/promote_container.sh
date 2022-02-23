#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Sync crostini lxd containers from staging to prod.
set -e -o pipefail

PROD_URL="gs://cros-containers"
STAGING_URL="gs://cros-containers-staging"

main() {
  local milestone=$1

  if [[ -z "${milestone}" ]]; then
    echo "usage: promote_container.sh milestone"
    exit 1
  fi

  if [[ "${milestone}" -lt 69 ]]; then
    echo "container pushes are only supported for M69+"
    exit 1
  fi

  local src_url="${STAGING_URL}"
  local target_url="${PROD_URL}"
  if [[ "${milestone}" -ge 70 ]]; then
    src_url="${src_url}/${milestone}"
    target_url="${target_url}/${milestone}"
  fi

  local dir
  for dir in images streams; do
    gsutil.py -- -h "Cache-Control:public,max-age=30" \
      -m rsync \
      -r \
      "${src_url}/${dir}/" "${target_url}/${dir}/"
  done
}

main "$@"
