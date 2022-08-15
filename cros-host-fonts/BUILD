# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-host-fonts-systemd",
    srcs = ["usr-share-fonts-chromeos.mount"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/system/",
    strip_prefix = "/cros-host-fonts",
)

pkg_tar(
    name = "debian-data",
    empty_dirs = ["/usr/share/fonts/chromeos"],
    extension = "tar.gz",
    deps = [
        ":cros-host-fonts-systemd",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-host-fonts",
    # We aren't building with dh-systemd, so these scripts implement the
    # relevant functionality to ensure that conffiles and systemd units are
    # correctly managed upon installation or removal.
    postinst = "postinst",
    postrm = "postrm",
    preinst = "preinst",
    prerm = "prerm",
    provides = [
        "fonts-roboto",
        "fonts-roboto-hinted",
        "fonts-roboto-unhinted",
    ],
    section = "misc",
    version = "0.3",
    visibility = ["//cros-debs:__pkg__"],
)
