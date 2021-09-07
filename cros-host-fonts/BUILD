# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-host-fonts-config",
    srcs = ["05-cros-fonts.conf"],
    mode = "0644",
    package_dir = "/etc/fonts/conf.d/",
    strip_prefix = "/cros-host-fonts",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-host-fonts-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-host-fonts",
    section = "misc",
    version = "0.1",
    visibility = ["//cros-debs:__pkg__"],
)
