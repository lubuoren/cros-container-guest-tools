# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "pulseaudio-config",
    srcs = [
        "daemon.conf",
        "default.pa",
    ],
    mode = "0644",
    package_dir = "/usr/share/cros-pulse-config",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":pulseaudio-config",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = ["pulseaudio"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-pulse-config",
    postinst = "postinst",
    prerm = "prerm",
    section = "misc",
    version = "0.2.1",
    visibility = ["//cros-debs:__pkg__"],
)
