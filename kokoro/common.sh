#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This is determined by the branch on kokoro.
# TODO(davidriley): This is somewhat misused and can also represent "mesa"
# which would be shared across multiple milestones.  This is intended to
# just be temporary while GPU is alpha/beta.
CROS_MILESTONE="$(echo "${KOKORO_JOB_NAME}" | cut -d'/' -f 3 -)"
