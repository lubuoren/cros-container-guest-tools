# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

genrule(
    name = "skel-config",
    srcs = ["skel.cros-garcon.conf"],
    outs = [".config/cros-garcon.conf"],
    cmd = "mv $(location skel.cros-garcon.conf) $@",
)

pkg_tar(
    name = "cros-garcon-desktop",
    srcs = ["garcon_host_browser.desktop"],
    mode = "0644",
    package_dir = "/usr/share/applications",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-etc-skel",
    srcs = [":skel-config"],
    mode = "0644",
    package_dir = "/etc/skel",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-systemd",
    srcs = ["cros-garcon.service"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/user",
    strip_prefix = "/cros-garcon",
    symlinks = {"./usr/lib/systemd/user/default.target.wants/cros-garcon.service": "/usr/lib/systemd/user/cros-garcon.service"},
)

pkg_tar(
    name = "cros-garcon-terminal-handler",
    srcs = ["garcon-terminal-handler"],
    mode = "0755",
    package_dir = "/usr/bin",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-url-handler",
    srcs = ["garcon-url-handler"],
    mode = "0755",
    package_dir = "/usr/bin",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-config",
    srcs = ["cros-garcon-override.conf"],
    mode = "0644",
    package_dir = "/etc/systemd/user/cros-garcon.service.d",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-polkit",
    srcs = [
        "garcon-packagekit.pkla",
        "garcon-synaptic.pkla",
    ],
    mode = "0644",
    package_dir = "/var/lib/polkit-1/localauthority/50-local.d",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-dpkg-config",
    srcs = ["garcon-hook"],
    mode = "0644",
    package_dir = "/etc/dpkg/dpkg.cfg.d",
    strip_prefix = "/cros-garcon",
)

pkg_tar(
    name = "cros-garcon-ansible-integration",
    srcs = ["third_party/garcon.py"],
    mode = "0644",
    package_dir = "/usr/share/ansible/plugins/callback",
    strip_prefix = "/cros-garcon/third_party",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-garcon-ansible-integration",
        ":cros-garcon-config",
        ":cros-garcon-desktop",
        ":cros-garcon-dpkg-config",
        ":cros-garcon-etc-skel",
        ":cros-garcon-polkit",
        ":cros-garcon-systemd",
        ":cros-garcon-terminal-handler",
        ":cros-garcon-url-handler",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conffiles_file = "conffiles",
    data = ":debian-data",
    depends = [
        "desktop-file-utils",
        "packagekit",
        "xdg-utils",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/garcon/",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-garcon",
    postinst = "postinst",
    prerm = "prerm",
    provides = ["x-terminal-emulator"],
    section = "misc",
    version = "0.27",
    visibility = ["//cros-debs:__pkg__"],
)
