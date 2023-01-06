#!/bin/bash
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This is determined by the branch on kokoro.
# TODO(davidriley): This is somewhat misused and can also represent "mesa"
# which would be shared across multiple milestones.  This is intended to
# just be temporary while GPU is alpha/beta.
CROS_MILESTONE="$(echo "${KOKORO_JOB_NAME}" | cut -d'/' -f 3 -)"

require_kokoro_artifacts() {
    if [ -z "${KOKORO_ARTIFACTS_DIR}" ]; then
        echo "This script must be run in kokoro"
        exit 1
    fi
}

require_cros_milestone() {
    if [ -z "${CROS_MILESTONE}" ]; then
        echo "CROS_MILESTONE must be set"
        exit 1
    fi
}

# Disable automatic apt activities. As this runs after the timers are activated,
# we must also wait for the services to finish if they already started.
stop_apt_daily() {
    sudo tee /etc/apt/apt.conf.d/99no-periodic > /dev/null << EOF
APT::Periodic::Enable "0";
EOF
    sudo flock -w 3600 /var/lib/apt/daily_lock echo "Acquired apt daily_lock"
}

function get_metadata() {
    key="$1"
    curl -fsS "http://metadata.google.internal/computeMetadata/v1/instance/$key" -H "Metadata-Flavor:Google"
}

print_instance_details() {
    cat << EOF || true
Instance name: $(get_metadata name)
Instance ID: $(get_metadata id)
Machine type: $(get_metadata machine-type)
CPU platform: $(get_metadata cpu-platform)
Zone: $(get_metadata zone)
OS image: $(get_metadata image)
Default service account: $(get_metadata service-accounts/default/email)
EOF
}
