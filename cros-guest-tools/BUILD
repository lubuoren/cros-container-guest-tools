# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "debian-data",
)


DEPENDS = [
    "cros-garcon",
    "cros-host-fonts",
    "cros-notificationd",
    "cros-sftp",
    "cros-sommelier",
    "cros-ui-config",
]

RECOMMENDS = [
    "bash-completion",
    "bzip2",
    "cros-apt-config",
    "cros-gpu",
    "cros-logging",
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
    "udev",
    "unzip",
    "usbutils",
    "vim",
    "wget",
    "xz-utils",
]

pkg_deb(
    name = "deb", #TODO(b/266349390): Rename this to be deb-bullseye.
    architecture = "all",
    data = ":debian-data",
    depends = DEPENDS + ["cros-im"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = RECOMMENDS + ["cros-pipe-config"],
    section = "misc",
    version = "0.34",
    visibility = ["//cros-debs:__pkg__"],
)

pkg_deb(
    name = "deb-buster",
    architecture = "all",
    data = ":debian-data",
    depends = DEPENDS,
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-guest-tools",
    recommends = RECOMMENDS + ["cros-pulse-config"],
    section = "misc",
    # This version should sort before the :deb version. This ensures that if
    # the container is upgraded, the :deb version is installed as an update.
    version = "0.34~cros10",
    visibility = ["//cros-debs:__pkg__"],
)