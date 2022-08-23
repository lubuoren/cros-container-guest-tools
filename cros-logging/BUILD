# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-logging-config",
    srcs = ["00-create-logs-dir.conf"],
    mode = "0644",
    package_dir = "/etc/tmpfiles.d/",
    strip_prefix = "/cros-logging",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-logging-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-logging",
    section = "misc",
    version = "0.2",
    visibility = ["//cros-debs:__pkg__"],
)
