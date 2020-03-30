# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-pulse-config-systemd",
    srcs = ["cros-pulse-config.service"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/user",
    strip_prefix = "/cros-pulse-config",
    symlinks = {"./usr/lib/systemd/user/default.target.wants/cros-pulse-config.service": "/usr/lib/systemd/user/cros-pulse-config.service"},
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-pulse-config-systemd",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = ["pulseaudio"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-pulse-config",
    section = "misc",
    version = "0.1.2",
    visibility = ["//cros-debs:__pkg__"],
)
