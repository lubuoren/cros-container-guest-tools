# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-notificationd-dbus-service-files",
    srcs = ["org.freedesktop.Notifications.service"],
    mode = "0644",
    package_dir = "/usr/share/dbus-1/services/",
    strip_prefix = "/cros-notificationd",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-notificationd-dbus-service-files",
    ],
)

pkg_deb(
    name = "cros-notificationd-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-notificationd",
    section = "misc",
    version = "0.1",
)
