# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load(":copy_debs.bzl", "copy_debs_to_folder")

# Packages which are the same across different Debian versions.
filegroup(
    name = "cros-debs-common",
    srcs = [
        "//cros-adapta:deb",
        "//cros-garcon:deb",
        "//cros-host-fonts:deb",
        "//cros-logging:deb",
        "//cros-notificationd:deb",
        "//cros-sftp:deb",
        "//cros-sommelier:deb",
        "//cros-sommelier-config:deb",
        "//cros-sudo-config:deb",
        "//cros-systemd-overrides:deb",
        "//cros-tast-tests:deb",
        "//cros-ui-config:deb",
        "//cros-vmstat-metrics:deb",
        "//cros-wayland:deb",
    ],
)

# Packages introduced in bullseye
filegroup(
    name = "cros-debs-bullseye",
    srcs = [
        "//cros-pipe-config:deb",
        "//cros-xdg-desktop-portal:deb",
    ],
)

filegroup(
    name = "bookworm-files",
    srcs = [
        ":cros-debs-bullseye",
        ":cros-debs-common",
        "//cros-apt-config:deb-bookworm",
        "//cros-guest-tools:deb-bookworm",
        "//cros-pulse-config:deb",
    ],
)

filegroup(
    name = "bullseye-files",
    srcs = [
        ":cros-debs-bullseye",
        ":cros-debs-common",
        "//cros-apt-config:deb-bullseye",
        "//cros-guest-tools:deb-bullseye",
        "//cros-pulse-config:deb",
    ],
)

filegroup(
    name = "buster-files",
    srcs = [
        ":cros-debs-common",
        "//cros-apt-config:deb-buster",
        "//cros-gpu-buster:deb",
        "//cros-guest-tools:deb-buster",
        "//cros-pulse-config:deb-buster",
    ],
)

copy_debs_to_folder(
    name = "bookworm-debs",
    srcs = [":bookworm-files"],
    out_dir = "bookworm-debs",
)

copy_debs_to_folder(
    name = "bullseye-debs",
    srcs = [":bullseye-files"],
    out_dir = "bullseye-debs",
)

copy_debs_to_folder(
    name = "buster-debs",
    srcs = [":buster-files"],
    out_dir = "buster-debs",
)

filegroup(
    name = "debs",
    srcs = [
        ":bookworm-debs",
        ":bullseye-debs",
        ":buster-debs",
    ],
)
