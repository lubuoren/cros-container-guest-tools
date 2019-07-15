# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-sudo-config",
    strip_prefix = "/cros-sudo-config",
    package_dir = "/etc/sudoers.d",
    srcs = ["10-cros-nopasswd"],
    mode = "0440",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sudo-config",
    ],
)

pkg_deb(
    name = "cros-sudo-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sudo-config",
    version = "0.10",
    section = "misc",
    conffiles_file = "conffiles",
    depends = ["sudo"],
)
