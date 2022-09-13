# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

genrule(
    name = "skel-config",
    srcs = ["skel.weston.ini"],
    outs = [".config/weston.ini"],
    cmd = "mv $(location skel.weston.ini) $@",
)

pkg_tar(
    name = "cros-wayland-etc-skel",
    srcs = [":skel-config"],
    mode = "0644",
    package_dir = "/etc/skel",
    strip_prefix = "/cros-wayland",
)

pkg_tar(
    name = "cros-wayland-udev",
    srcs = ["10-cros-virtwl.rules"],
    mode = "0644",
    package_dir = "/lib/udev/rules.d",
    strip_prefix = "/cros-wayland",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-wayland-etc-skel",
        ":cros-wayland-udev",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-wayland",
    section = "x11",
    version = "0.11",
    visibility = ["//cros-debs:__pkg__"],
)
