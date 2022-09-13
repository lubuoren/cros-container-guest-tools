# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-sommelier-elf",
    package_dir = "/usr/bin",
    strip_prefix = "/cros-sommelier",
    symlinks = {
        "./usr/bin/sommelier.elf": "/opt/google/cros-containers/bin/sommelier.elf",
    },
)

pkg_tar(
    name = "cros-sommelier-unitfiles",
    srcs = [
        "sommelier-x@.service",
        "sommelier@.service",
    ],
    mode = "0644",
    package_dir = "/usr/lib/systemd/user/",
    strip_prefix = "/cros-sommelier",
)

pkg_tar(
    name = "cros-sommelierrc",
    srcs = ["sommelierrc"],
    mode = "0644",
    package_dir = "/etc",
    strip_prefix = "/cros-sommelier",
)

pkg_tar(
    name = "cros-sommelier-profiled",
    srcs = ["sommelier.sh"],
    mode = "0644",
    package_dir = "/etc/profile.d",
    strip_prefix = "/cros-sommelier",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sommelier-elf",
        ":cros-sommelier-etc-skel",
        ":cros-sommelier-profiled",
        ":cros-sommelier-unitfiles",
        ":cros-sommelierrc",
    ],
)

genrule(
    name = "skel-config",
    srcs = ["skel.sommelierrc"],
    outs = [".sommelierrc"],
    cmd = "mv $(location skel.sommelierrc) $@",
)

pkg_tar(
    name = "cros-sommelier-etc-skel",
    srcs = [":skel-config"],
    mode = "0644",
    package_dir = "/etc/skel",
    strip_prefix = "/cros-sommelier",
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    depends = [
        "libgtk2.0-0",
        "libpam-systemd",
        "x11-utils",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/sommelier/",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sommelier",
    recommends = [
        "x11-xserver-utils",
        "xauth",
        "xfonts-base",
        "xkb-data",
    ],
    section = "misc",
    version = "0.28",
    visibility = ["//cros-debs:__pkg__"],
)
