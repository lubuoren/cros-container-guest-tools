#!/bin/bash
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex -o pipefail

. "$(dirname "$0")/common.sh" || exit 1

# TODO(b/146575733): Currently there is a bug where kokoro jobs that have a
# group_spec as the initial trigger will fire continuously. In order to
# work around that bug, we will define a new no-op job to act as the head,
# whose child will be that group_spec job.
#
# Once the bug is fixed, we can go back to using the group_spec job as the
# trigger.
main() {
  # Print the date because why not.
  date
}

main "$@"
