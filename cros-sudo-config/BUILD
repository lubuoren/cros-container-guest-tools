# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-sudo-config",
    srcs = ["10-cros-nopasswd"],
    mode = "0440",
    package_dir = "/etc/sudoers.d",
    strip_prefix = "/cros-sudo-config",
)

pkg_tar(
    name = "cros-pkexec-config",
    srcs = ["10-cros-nopasswd.pkla"],
    mode = "0440",
    package_dir = "/var/lib/polkit-1/localauthority/10-vendor.d",
    strip_prefix = "/cros-sudo-config",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-pkexec-config",
        ":cros-sudo-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    depends = ["sudo"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sudo-config",
    section = "misc",
    version = "0.12",
    visibility = ["//cros-debs:__pkg__"],
)
