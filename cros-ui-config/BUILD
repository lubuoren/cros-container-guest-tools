# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "gtk2-config",
    srcs = ["gtkrc"],
    mode = "0644",
    package_dir = "/etc/gtk-2.0/",
    strip_prefix = "/cros-ui-config",
)

pkg_tar(
    name = "gtk3-config",
    srcs = ["settings.ini"],
    mode = "0644",
    package_dir = "/etc/gtk-3.0/",
    strip_prefix = "/cros-ui-config",
)

pkg_tar(
    name = "qt4-config",
    srcs = ["Trolltech.conf"],
    mode = "0644",
    package_dir = "/etc/xdg/",
    strip_prefix = "/cros-ui-config",
)

pkg_tar(
    name = "dconf-config",
    srcs = ["01-cros-ui"],
    mode = "0644",
    package_dir = "/etc/dconf/db/local.d/",
    strip_prefix = "/cros-ui-config",
)

pkg_tar(
    name = "dconf-profile",
    srcs = ["user"],
    mode = "0644",
    package_dir = "/etc/dconf/profile/",
    strip_prefix = "/cros-ui-config",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":dconf-config",
        ":dconf-profile",
        ":gtk2-config",
        ":gtk3-config",
        ":qt4-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    depends = [
        "cros-adapta",
        "dconf-cli",
        "fonts-croscore",
        "fonts-roboto",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-ui-config",
    postinst = "postinst",
    postrm = "postrm",
    section = "misc",
    version = "0.12",
    visibility = ["//cros-debs:__pkg__"],
)
