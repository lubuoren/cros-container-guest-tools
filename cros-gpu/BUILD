# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

genrule(
    name = "llvm-keyring-gpg",
    srcs = ["llvm-snapshot.gpg.key"],
    outs = ["llvm-snapshot.gpg"],
    cmd = """gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --import $(location llvm-snapshot.gpg.key) && \
             gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --export > $@""",
)

pkg_tar(
    name = "llvm-keyring",
    strip_prefix = "/cros-gpu",
    package_dir = "//etc/apt/trusted.gpg.d",
    srcs = ["llvm-snapshot.gpg"],
    mode = "0644",
)

pkg_tar(
    name = "cros-gpu-list",
    strip_prefix = "/cros-gpu",
    package_dir = "/etc/apt/sources.list.d",
    srcs = ["cros-gpu.list"],
    mode = "0644",
)

pkg_tar(
    name = "cros-gpu-pref",
    strip_prefix = "/cros-gpu",
    package_dir = "/etc/apt/preferences.d",
    srcs = ["cros-gpu.pref"],
    mode = "0644",
)

pkg_tar(
    name = "cros-unattended-upgrades",
    strip_prefix = "/cros-gpu",
    package_dir = "/etc/apt/apt.conf.d",
    srcs = ["96cros-unattended-upgrades"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-gpu-list",
        ":cros-gpu-pref",
        ":cros-unattended-upgrades",
        ":llvm-keyring",
    ],
)

pkg_deb(
    name = "cros-gpu-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-gpu",
    version = "0.4",
    section = "misc",
    depends = ["apt-transport-https"],
    conflicts = ["cros-gpu-alpha"],
)
