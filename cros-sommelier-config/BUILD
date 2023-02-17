# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-sommelier-config",
    srcs = ["cros-sommelier-override.conf"],
    mode = "0644",
    package_dir = "/etc/systemd/user/sommelier@0.service.d",
    strip_prefix = "/cros-sommelier-config",
)

pkg_tar(
    name = "cros-sommelier-x-config",
    srcs = ["cros-sommelier-x-override.conf"],
    mode = "0644",
    package_dir = "/etc/systemd/user/sommelier-x@0.service.d",
    strip_prefix = "/cros-sommelier-config",
)

pkg_tar(
    name = "cros-sommelier-low-density-config",
    srcs = [
        "cros-sommelier-low-density-override.conf",
        "cros-sommelier-override.conf",
    ],
    mode = "0644",
    package_dir = "/etc/systemd/user/sommelier@1.service.d",
    strip_prefix = "/cros-sommelier-config",
)

pkg_tar(
    name = "cros-sommelier-x-low-density-config",
    srcs = [
        "cros-sommelier-low-density-override.conf",
        "cros-sommelier-x-override.conf",
    ],
    mode = "0644",
    package_dir = "/etc/systemd/user/sommelier-x@1.service.d",
    strip_prefix = "/cros-sommelier-config",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sommelier-config",
        ":cros-sommelier-low-density-config",
        ":cros-sommelier-x-config",
        ":cros-sommelier-x-low-density-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    depends = [
        "libpam-systemd",
        "cros-sommelier",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/sommelier/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sommelier-config",
    postinst = "postinst",
    preinst = "preinst",
    prerm = "prerm",
    section = "misc",
    version = "0.16",
    visibility = ["//cros-debs:__pkg__"],
)
