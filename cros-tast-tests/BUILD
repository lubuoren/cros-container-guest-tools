# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-tast-tests-desktop",
    srcs = [
        "wayland_demo.desktop",
        "wayland_demo_fixed_size.desktop",
        "x11_demo.desktop",
        "x11_demo_fixed_size.desktop",
    ],
    mode = "0644",
    package_dir = "/usr/share/applications",
    strip_prefix = "/cros-tast-tests",
)

pkg_tar(
    name = "cros-tast-tests-icon",
    srcs = [
        "wayland_demo.png",
        "x11_demo.png",
    ],
    mode = "0644",
    package_dir = "/usr/share/icons/hicolor/32x32/apps",
    strip_prefix = "/cros-tast-tests",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-tast-tests-desktop",
        ":cros-tast-tests-icon",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-tast-tests",
    section = "misc",
    version = "0.5",
    visibility = ["//cros-debs:__pkg__"],
)
