# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-sftp-unitfiles",
    srcs = ["cros-sftp.service"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/system/",
    strip_prefix = "/cros-sftp",
    symlinks = {"./usr/lib/systemd/system/default.target.wants/cros-sftp.service": "/usr/lib/systemd/system/cros-sftp.service"},
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sftp-unitfiles",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = ["openssh-server"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sftp",
    section = "misc",
    version = "0.15",
    visibility = ["//cros-debs:__pkg__"],
)
