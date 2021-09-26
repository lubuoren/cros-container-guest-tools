# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load(":copy_debs.bzl", "copy_debs_to_folder")

# Packages which are the same across different Debian versions.
filegroup(
    name = "cros-debs-common",
    srcs = [
        "//cros-adapta:deb",
        "//cros-apt-config:deb",
        "//cros-garcon:deb",
        "//cros-guest-tools:deb",
        "//cros-host-fonts:deb",
        "//cros-logging:deb",
        "//cros-notificationd:deb",
        "//cros-pulse-config:deb",
        "//cros-sftp:deb",
        "//cros-sommelier:deb",
        "//cros-sommelier-config:deb",
        "//cros-sudo-config:deb",
        "//cros-systemd-overrides:deb",
        "//cros-tast-tests:deb",
        "//cros-ui-config:deb",
        "//cros-wayland:deb",
    ],
)

filegroup(
    name = "bullseye-files",
    srcs = [
        ":cros-debs-common",
    ],
)

filegroup(
    name = "buster-files",
    srcs = [
        ":cros-debs-common",
        "//cros-gpu-buster:deb",
    ],
)

copy_debs_to_folder(
    name = "buster-debs",
    srcs = [":buster-files"],
    out_dir = "buster-debs",
)

copy_debs_to_folder(
    name = "bullseye-debs",
    srcs = [":bullseye-files"],
    out_dir = "bullseye-debs",
)

filegroup(
    name = "debs",
    srcs = [
        ":bullseye-debs",
        ":buster-debs",
    ],
)
