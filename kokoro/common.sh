#!/bin/bash
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This is determined by the branch on kokoro.
CROS_MILESTONE="$(echo "${KOKORO_JOB_NAME}" | cut -d'/' -f 3 -)"
