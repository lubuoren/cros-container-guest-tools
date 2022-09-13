# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-adapta-symlinks",
    symlinks = {"./usr/share/themes/CrosAdapta": "/opt/google/cros-containers/cros-adapta"},
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-adapta-symlinks",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = [
        "gtk2-engines-murrine",
        "gtk2-engines-pixbuf",
        "libgtk2.0-0",
        "libgtk-3-0",
        "qt5-gtk-platformtheme",
        "qt5-style-plugins",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/third_party/cros-adapta/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-adapta",
    section = "misc",
    version = "0.4",
    visibility = ["//cros-debs:__pkg__"],
)
