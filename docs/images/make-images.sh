#!/bin/bash
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -ex

for type in png svg; do
    dot -T"${type}" kokoro_guest_flow.dot -o "kokoro_guest_flow.${type}"
done
