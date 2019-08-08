# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "debian-data",
)

pkg_deb(
    name = "cros-guest-tools-deb",
    architecture = "all",
    data = ":debian-data",
    depends = [
        "cros-garcon",
        "cros-notificationd",
        "cros-sftp",
        "cros-sommelier",
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
        "cros-pulse-config",
        "cros-sommelier-config",
        "cros-sudo-config",
        "cros-systemd-overrides",
        "cros-ui-config",
        "cros-wayland",
        "curl",
        "dbus-user-session",
        "dbus-x11",
        "file",
        "git",
        "gnupg",
        "iputils-ping",
        "less",
        "libxss1",
        "man-db",
        "pulseaudio",
        "unzip",
        "usbutils",
        "vim",
        "wget",
    ],
    section = "misc",
    version = "0.23",
)
