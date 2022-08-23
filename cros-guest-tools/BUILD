# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "debian-data",
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = [
        "cros-garcon",
        "cros-host-fonts",
        "cros-notificationd",
        "cros-sftp",
        "cros-sommelier",
        "cros-ui-config",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = [
        "bash-completion",
        "bzip2",
        "cros-apt-config",
        "cros-gpu",
        "cros-im",
        "cros-logging",
        "cros-pulse-config",
        "cros-sommelier-config",
        "cros-sudo-config",
        "cros-systemd-overrides",
        "cros-wayland",
        "curl",
        "dbus-user-session",
        "dbus-x11",
        "file",
        "fuse",
        "git",
        "gnupg",
        "iputils-ping",
        "iptables",
        "less",
        "libxss1",
        "man-db",
        "pulseaudio",
        "udev",
        "unzip",
        "usbutils",
        "vim",
        "wget",
        "xz-utils",
    ],
    section = "misc",
    version = "0.31",
    visibility = ["//cros-debs:__pkg__"],
)
