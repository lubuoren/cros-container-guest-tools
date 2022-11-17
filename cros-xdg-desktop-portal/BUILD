# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This package is experimental and we are not installing it by default yet.
load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "portal-config",
    srcs = [
        "cros.portal",
    ],
    mode = "0644",
    package_dir = "/usr/share/xdg-desktop-portal/portals",
    strip_prefix = "/cros-xdg-desktop-portal",
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":portal-config",
    depends = ["xdg-desktop-portal"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-xdg-desktop-portal",
    section = "admin",
    version = "0.1",
    visibility = ["//cros-debs:__pkg__"],
)
